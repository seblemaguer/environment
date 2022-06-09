#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
AUTHOR

    Sébastien Le Maguer <sebastien.lemaguer@adaptcentre.ie>

DESCRIPTION

LICENSE
    This script is in the public domain, free from copyrights or restrictions.
    Created:  6 March 2022
"""
import os

# Arguments and configuration
import argparse
from xdg.BaseDirectory import load_first_config, save_data_path

import json
import uuid
import base64

# Networking
import urllib
import urllib.request
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs, urlencode
from wsgiref import simple_server
import wsgiref.util
import webbrowser
import msal

# Messaging/logging
import logging
from logging.config import dictConfig

###############################################################################
# global constants
###############################################################################
LEVEL = [logging.WARNING, logging.INFO, logging.DEBUG]

APP_NAME = "oauth2mail"

###############################################################################
# Functions
###############################################################################
def configure_logger(args) -> logging.Logger:
    """Setup the global logging configurations and instanciate a specific logger for the current script

    Parameters
    ----------
    args : dict
        The arguments given to the script

    Returns
    --------
    the logger: logger.Logger
    """
    # create logger and formatter
    logger = logging.getLogger()

    # Verbose level => logging level
    log_level = args.verbosity
    if args.verbosity >= len(LEVEL):
        log_level = len(LEVEL) - 1
        # logging.warning("verbosity level is too high, I'm gonna assume you're taking the highest (%d)" % log_level)

    # Define the default logger configuration
    logging_config = dict(
        version=1,
        disable_existing_logger=True,
        formatters={
            "f": {
                "format": "[%(asctime)s] [%(levelname)s] — [%(name)s — %(funcName)s:%(lineno)d] %(message)s",
                "datefmt": "%d/%b/%Y: %H:%M:%S ",
            }
        },
        handlers={
            "h": {
                "class": "logging.StreamHandler",
                "formatter": "f",
                "level": LEVEL[log_level],
            }
        },
        root={"handlers": ["h"], "level": LEVEL[log_level]},
    )

    # Add file handler if file logging required
    if args.log_file is not None:
        logging_config["handlers"]["f"] = {
            "class": "logging.FileHandler",
            "formatter": "f",
            "level": LEVEL[log_level],
            "filename": args.log_file,
        }
        logging_config["root"]["handlers"] = ["h", "f"]

    # Setup logging configuration
    dictConfig(logging_config)

    # Retrieve and return the logger dedicated to the script
    logger = logging.getLogger(__name__)
    return logger


def define_argument_parser() -> argparse.ArgumentParser:
    """Defines the argument parser

    Returns
    --------
    The argument parser: argparse.ArgumentParser
    """
    parser = argparse.ArgumentParser(description="")

    # Add options
    parser.add_argument("-e", "--encode-xoauth2", action="store_true", help="Activate XOAUTH2 base 64 encoding")
    parser.add_argument("-c", "--config", default=None, help="The configuration file")
    parser.add_argument("-l", "--log_file", default=None, help="Logger file")
    parser.add_argument(
        "-v",
        "--verbosity",
        action="count",
        default=0,
        help="increase output verbosity",
    )

    # Add arguments
    parser.add_argument("account_id", help="The account ID")

    # Return parser
    return parser


def load_config(config_file=None):
    global logger

    # Nothing specified, try to load the default configuration
    if config_file is None:
        config_file = load_first_config(APP_NAME, "default.json")

    # That fails too
    if config_file is None:
        logger.error(
            f"Couldn't find configuration file. Config file must be at: $XDG_CONFIG_HOME/{APP_NAME}/default.json"
        )
        logger.error(
            "Current value of $XDG_CONFIG_HOME is {}".format(
                os.getenv("XDG_CONFIG_HOME")
            )
        )
        return None

    return json.load(open(config_file, "r"))


class WSGIRequestHandler(wsgiref.simple_server.WSGIRequestHandler):
    """Silence out the messages from the http server"""

    def log_message(self, format, *args):
        pass


class WSGIRedirectionApp(object):
    """WSGI app to handle the authorization redirect.

    Stores the request URI and displays the given success message.
    """

    def __init__(self, message):
        self.last_request_uri = None
        self._success_message = message

    def __call__(self, environ, start_response):
        start_response("200 OK", [("Content-type", "text/plain; charset=utf-8")])
        self.last_request_uri = wsgiref.util.request_uri(environ)
        return [self._success_message.encode("utf-8")]


class OAuth2Authenticator:
    def __init__(self, client_id, client_secret, encode_xoauth2, **kwargs):
        self._client_id = client_id
        self._client_secret = client_secret
        self._activate_encode_xoauth2 = encode_xoauth2

    def get_acces_token(self):
        pass

    def _encode_xoauth2(self, user, token):
        """
        Encode the xoauth 2 message based on:
        https://docs.microsoft.com/en-us/exchange/client-developer/legacy-protocols/how-to-authenticate-an-imap-pop-smtp-application-by-using-oauth#sasl-xoauth2
        """
        C_A = b'\x01'
        user = ("user=" + user).encode("ascii")
        btoken = ("auth=Bearer " + token).encode("ascii")
        xoauth2_bytes = user + C_A + btoken + C_A + C_A
        return base64.b64encode(xoauth2_bytes).decode("utf-8")


class MSOauth2(OAuth2Authenticator):
    SUCCESS_MESSAGE = "Authorization complete."

    def __init__(self, client_id, client_secret, encode_xoauth2, **kwargs):
        super().__init__(client_id, client_secret, encode_xoauth2, **kwargs)

      # Basic
        self._tenant_id = "common"

        # Some needed redirection
        self._redirect_host = "localhost"
        self._redirect_port = "5000"
        # self._redirect_path = "/getToken/"
        self._redirect_path = "/"
        self._redirect_uri = self._generate_redirect_uri()

        #
        self._credentials_file = save_data_path(APP_NAME) + f"/{client_id}.bin"

        # Scopes
        self._scopes = [
            "https://outlook.office365.com/IMAP.AccessAsUser.All",
            # "https://outlook.office.com/SMTP.Send",
        ]
        self._browser_activated = False

    def get_access_token(self):
        crypt = None
        # if cmdline_args.encrypt_using_fingerprint:
        #     gpg_args = {"gnupghome": cmdline_args.gpg_home} if cmdline_args.gpg_home else {}
        #     gpg = gnupg.GPG(**gpg_args)
        #     crypt = {"gpg" : gpg,
        #              "fingerprint": cmdline_args.encrypt_using_fingerprint}

        token = None
        app_state = self._build_app_state_from_credentials(crypt)
        if app_state is None:
            app_state, token = self._build_new_app_state(crypt)

        if app_state is None:
            raise Exception("Something went wrong!")

        if token is None:
            token = self._fetch_token_from_cache(app_state)

        cache = app_state['cache']
        if cache.has_state_changed:
            token_cache = cache.serialize()
            config_json = json.dumps(token_cache)
            crypt = app_state.get("crypt")
            if crypt:
                gpg = crypt["gpg"]
                fingerprint = crypt["fingerprint"]
                config_json = str(gpg.encrypt(config_json, fingerprint))
            open(self._credentials_file, "w").write(config_json)


        assert token is not None

        if self._activate_encode_xoauth2:
            return self._encode_xoauth2(app_state, token)
        else:
            return token



    def _encode_xoauth2(self, app, token):
        """
        Encode the xoauth 2 message based on:
        https://docs.microsoft.com/en-us/exchange/client-developer/legacy-protocols/how-to-authenticate-an-imap-pop-smtp-application-by-using-oauth#sasl-xoauth2
        """
        cache = app['cache']
        cca = self._build_msal_app(cache)
        accounts = cca.get_accounts()
        username = accounts[0]["username"]
        return super()._encode_xoauth2(username, token)

    def _generate_redirect_uri(self):
        redirect_path = self._redirect_path
        # Remove / at the end if present, and path is not just /
        if redirect_path != "/" and redirect_path[-1] == "/":
            redirect_path = redirect_path[:-1]

        return (
            "http://"
            + self._redirect_host
            + ":"
            + self._redirect_port
            + redirect_path
        )

    def _build_new_app_state(self, crypt):
        cache = msal.SerializableTokenCache()

        state = str(uuid.uuid4())

        auth_url = self._get_auth_url(cache, state)
        wsgi_app = WSGIRedirectionApp(MSOauth2.SUCCESS_MESSAGE)
        http_server = simple_server.make_server(
            self._redirect_host,
            int(self._redirect_port),
            wsgi_app,
            handler_class=WSGIRequestHandler,
        )

        if not self._browser_activated:
            print("Please navigate to this url: " + auth_url)
        else:
            webbrowser.open(auth_url, new=2, autoraise=True)

        http_server.handle_request()

        auth_response = wsgi_app.last_request_uri
        http_server.server_close()
        parsed_auth_response = parse_qs(auth_response)

        code_key = self._redirect_uri + "?code"
        if code_key not in parsed_auth_response:
            raise Exception(f"A coder key was expected from {parsed_auth_response}")

        auth_code = parsed_auth_response[code_key]

        result = self._build_msal_app(cache).acquire_token_by_authorization_code(
            auth_code, scopes=self._scopes, redirect_uri=self._redirect_uri
        )

        if result.get("access_token") is None:
            raise Exception(f"Something went wrong during authorization Server returned: {result}")

        token = result["access_token"]
        app = {}
        app["cache"] = cache
        app["crypt"] = crypt
        return app, token

    def _fetch_token_from_cache(self, app):
        cache = app["cache"]
        cca = self._build_msal_app(cache)
        accounts = cca.get_accounts()
        if cca.get_accounts:
            result = cca.acquire_token_silent(self._scopes, account=accounts[0])
            return result["access_token"]
        else:
            None

    def _build_app_state_from_credentials(self, crypt):
        # If the file is missing return None
        if not os.path.exists(self._credentials_file):
            return None

        credentials = open(self._credentials_file, "r").read()
        if crypt:
            gpg = crypt["gpg"]
            credentials = str(gpg.decrypt(credentials))

        # Make sure it is a valid json object
        try:
            token_cache = json.loads(credentials)
        except:
            raise Exception(
                "Not a valid json file or it is ecrypted. Maybe add/remove the -e arugment?"
            )


        app_state = {}
        cache = msal.SerializableTokenCache()
        cache.deserialize(token_cache)
        app_state["cache"] = cache
        app_state["crypt"] = crypt
        return app_state

    def _build_msal_app(self, cache=None):
        return msal.ConfidentialClientApplication(
            self._client_id,
            authority="https://login.microsoftonline.com/" + self._tenant_id,
            client_credential=self._client_secret,
            token_cache=cache,
        )

    def _get_auth_url(self, cache, state):
        return self._build_msal_app(cache).get_authorization_request_url(
            self._scopes, state=state, redirect_uri=self._redirect_uri
        )


class GoogleOauth2(OAuth2Authenticator):
    def __init__(self, user, client_id, client_secret, refresh_token=None, **kwargs):
        super().__init__(client_id, client_secret, **kwargs)
        self._user = user
        self._refresh_token = refresh_token

        # The URL root for accessing Google Accounts.
        self._GOOGLE_ACCOUNTS_BASE_URL = "https://accounts.google.com"

        # Hardcoded dummy redirect URI for non-web apps.
        self._REDIRECT_URI = "urn:ietf:wg:oauth:2.0:oob"

    def _accounts_url(self, command):
        """Generates the Google Accounts URL.

        Args:
          command: The command to execute.

        Returns:
          A URL for the given command.
        """
        return "%s/%s" % (self._GOOGLE_ACCOUNTS_BASE_URL, command)

    def get_access_token(self):
        """Obtains a new token given a refresh token.

        See https://developers.google.com/accounts/docs/OAuth2InstalledApp#refresh

        Args:
          client_id: Client ID obtained by registering your app.
          client_secret: Client secret obtained by registering your app.
          refresh_token: A previously-obtained refresh token.
        Returns:
          The decoded response from the Google Accounts server, as a dict. Expected
          fields include 'access_token', 'expires_in', and 'refresh_token'.
        """
        if self._refresh_token is None:
            self.refresh_token()

        params = {}
        params["client_id"] = self._client_id
        params["client_secret"] = self._client_secret
        params["refresh_token"] = self._refresh_token
        params["grant_type"] = "refresh_token"
        request_url = self._accounts_url("o/oauth2/token")

        response = urllib.request.urlopen(
            request_url, urllib.parse.urlencode(params).encode("utf-8")
        ).read()
        token = json.loads(response)["access_token"]

        if self._activate_encode_xoauth2:
            return self._encode_xoauth2(self._user, token)
        else:
            return token



###############################################################################
#  Envelopping
###############################################################################
if __name__ == "__main__":
    # Initialization
    arg_parser = define_argument_parser()
    args = arg_parser.parse_args()
    logger = configure_logger(args)

    # TODO: your code comes here
    cur_config = load_config(args.config)
    if not (args.account_id in cur_config):
        raise Exception(f"{args.account_id} doesn't have any configuration associated")

    cur_config = cur_config[args.account_id]
    if not ("type" in cur_config):
        raise Exception(f"The type entry is not available for account {args.account_id}")

    if cur_config["type"] == "gmail":
        auth = GoogleOauth2(user=args.account_id, encode_xoauth2=args.encode_xoauth2, **cur_config)
    elif cur_config["type"] == "outlook":
        auth = MSOauth2(encode_xoauth2=args.encode_xoauth2, **cur_config)
    else:
        raise Exception(f"{cur_config['type']} is an unkown type")
    print(auth.get_access_token())
