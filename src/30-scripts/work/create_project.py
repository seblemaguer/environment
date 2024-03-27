#!/usr/bin/python3

from typing_extensions import override
import argparse
from pathlib import Path


class ProjectDirectoryStructure:
    """Class to create directory structure for a project."""

    def __init__(self, project_name: str):
        """
        Initialize ProjectDirectoryStructure.

        Args:
            project_name (str): The name of the project.
        """
        self.project_name = project_name.lower().replace(" ", "_")
        self.directories: dict[str, list[str]] = {
            "documents": ["papers", "presentations", "reports", "manuals"],
            "scripts": [
                "data_preprocessing",
                "analysis",
                "visualization",
                "models",
                "utilities",
            ],
            "experiments": [],
            "data": ["raw_data", "processed_data", "results", "metadata"],
            "tools": [],
            "resources": ["external_resources", "figures"],
        }

    def create_directory(self, directory_path: Path) -> None:
        """
        Create a directory if it does not exist.

        Args:
            directory_path (Path): The path of the directory to create.
        """
        directory_path.mkdir(parents=True, exist_ok=True)

    def create_readme(self, directory_path: Path) -> None:
        """
        Create a README file for the directory.

        Args:
            directory_path (Path): The path of the directory to create the README for.
        """
        with open(directory_path / "README.org", "w") as f:
            _ = f.write(f"#+TITLE: {directory_path.name.capitalize()}\n\n")
            _ = f.write("* Description \n\n")
            _ = f.write(
                "* References\n\nUse org-transclusion here to insert files from the org-roam part\n\n"
            )

    def create_directory_structure(self) -> None:
        """Create the directory structure for the project."""
        # Create main project directory
        root_dir = Path(self.project_name)
        self.create_directory(root_dir)
        self.create_readme(root_dir)

        # Create subdirectories and README files
        for directory, subdirs in self.directories.items():
            directory_path = root_dir / directory
            self.create_directory(directory_path)

            for subdir in subdirs:
                subdir_path = directory_path / subdir
                self.create_directory(subdir_path)


class PersonalProjectDirectoryStructure(ProjectDirectoryStructure):
    """Class to create directory structure for a personal project."""

    def __init__(self, project_name: str):
        """
        Initialize PersonalProjectDirectoryStructure.

        Args:
            project_name (str): The name of the project.
        """
        super().__init__(project_name)
        self.directories: dict[str, list[str]] = {
            "code": ["src", "tests"],
            "data": ["input", "output"],
            "docs": ["documentation"],
        }

    @override
    def create_directory_structure(self) -> None:
        """Create the directory structure for the personal project."""
        # Create main project directory
        root_dir = Path(self.project_name)
        self.create_directory(root_dir)
        self.create_readme(root_dir)

        # Create subdirectories and README files
        for directory, subdirs in self.directories.items():
            directory_path = Path(root_dir) / directory
            self.create_directory(directory_path)

            for subdir in subdirs:
                subdir_path = directory_path / subdir
                self.create_directory(subdir_path)


class SupportProjectDirectoryStructure(ProjectDirectoryStructure):
    """Class to create directory structure for a support project."""

    def __init__(self, project_name: str):
        """
        Initialize SupportProjectDirectoryStructure.

        Args:
            project_name (str): The name of the project.
        """
        super().__init__(project_name)

        self.directories: dict[str, list[str]] = {
            "code": ["src", "tests"],
        }

    def create_directory_structure(self) -> None:
        """Create the directory structure for the support project."""
        # Create main project directory
        root_dir = Path(self.project_name)
        self.create_directory(root_dir)
        self.create_readme(root_dir)

        # Create subdirectories and README files
        for directory, subdirs in self.directories.items():
            directory_path = root_dir / directory
            self.create_directory(directory_path)

            for subdir in subdirs:
                subdir_path = directory_path / subdir
                self.create_directory(subdir_path)


class PythonProjectDirectoryStructure(ProjectDirectoryStructure):
    """Class to create directory structure for a Python project."""

    def __init__(self, project_name: str):
        """
        Initialize PythonProjectDirectoryStructure.

        Args:
            project_name (str): The name of the project.
        """
        super().__init__(project_name)
        self.directories = {
            "src": [],
            "tests": [],
        }

    @override
    def create_directory_structure(self) -> None:
        """Create the directory structure for the Python project."""
        super().create_directory_structure()

        self.create_pyproject_toml()

        # Create src directory
        src_path = Path(self.project_name) / "src"
        self.create_directory(src_path)

        # Create Python package structure
        package_name = self.project_name.lower().replace(" ", "_")
        package_path = src_path / package_name
        self.create_directory(package_path)

        # Create __init__.py file
        with open(package_path / "__init__.py", "w") as f:
            _ = f.write('__all__ = [""]')

        # Create tests directory
        tests_path = Path(self.project_name) / "tests"
        self.create_directory(tests_path)

        # Create pyproject.toml file
        self.create_pyproject_toml()

    def create_pyproject_toml(self) -> None:
        """Create pyproject.toml file for the project."""
        package_name = self.project_name.lower().replace(" ", "_")

        pyproject_content = f"""
[build-system]
requires = ["setuptools", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "{self.project_name}"
version = "0.0.1"
description = "Brief description of your project"
readme = {{file="README.org", content-type = "text/org-mode"}}
authors = [
   {{name="Sébastien Le Maguer", email="sebastien.lemaguer@helsinki.fi"}}
]
license = ""
keywords = []
requires-python = ">=3.11"
classifiers = [
]
dependencies = [
]
[project.optional-dependencies]
dev = [
  "pre-commit",
]
[project.urls]
Homepage = "https://github.com/seblemaguer/{package_name}"
Issues = "https://github.com/seblemaguer/{package_name}/issues"
git = "https://github.com/seblemaguer/{package_name}.git"

[tool.black]
line-length = 120

[tool.isort]
profile = "black"
line_length = 120

[tool.flake8]
max-line-length = 120  # Adjusted to 120 characters
extend-ignore = "E203, W503"  # Adjust as per your preferences

[tool.mypy]
python_version = 3.11
warn_return_any = true
warn_unused_configs = true
disallow_untyped_calls = true
check_untyped_defs = true
ignore_missing_imports = true

[tool.basedpyright]
typeCheckingMode = "standard"

[tool.pre_commit]
version = "2.15.0"
hooks = ["black", "isort", "flake8"]
        """

        pyproject_path = Path(self.project_name) / "pyproject.toml"
        with open(pyproject_path, "w") as f:
            _ = f.write(pyproject_content.strip())


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Create directory structure for research or personal project."
    )
    _ = parser.add_argument(
        "-t",
        "--project-type",
        choices=["research", "personal", "support", "python"],
        default="research",
        type=str,
        help="Type of project: research or personal",
    )
    _ = parser.add_argument("project_name", type=str)
    args = parser.parse_args()

    if args.project_type == "research":
        project = ProjectDirectoryStructure(args.project_name)
    elif args.project_type == "personal":
        project = PersonalProjectDirectoryStructure(args.project_name)
    elif args.project_type == "support":
        project = SupportProjectDirectoryStructure(args.project_name)
    elif args.project_type == "python":
        project = PythonProjectDirectoryStructure(args.project_name)
    else:
        print("Invalid project type specified.")
        exit(1)

    project.create_directory_structure()
    print("Project structure created successfully.")
