#!/usr/bin/python3

import argparse
from pathlib import Path
from typing import List, Dict


class ProjectDirectoryStructure:
    """Class to create directory structure for a project."""

    def __init__(self, project_name: str):
        """
        Initialize ProjectDirectoryStructure.

        Args:
            project_name (str): The name of the project.
        """
        self.project_name = project_name.lower().replace(" ", "_")
        self.directories: Dict[str, List[str]] = {
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
            f.write(f"#+TITLE: {directory_path.name.capitalize()}\n\n")
            f.write("* Description \n\n")
            f.write(
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
        self.directories: Dict[str, List[str]] = {
            "code": ["src", "tests"],
            "data": ["input", "output"],
            "docs": ["documentation"],
        }

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

        self.directories: Dict[str, List[str]] = {
            "code": ["src", "tests"],
            "data": [],
            "docs": ["documentation"],
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


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Create directory structure for research or personal project."
    )
    parser.add_argument(
        "-t", "--project-type",
        choices=["research", "personal", "support"],
        default="research",
        help="Type of project: research or personal",
    )
    parser.add_argument("project_name")
    args = parser.parse_args()

    if args.project_type == "research":
        project = ProjectDirectoryStructure(args.project_name)
    elif args.project_type == "personal":
        project = PersonalProjectDirectoryStructure(args.project_name)
    elif args.project_type == "support":  # Add condition for "support" project type
        project = SupportProjectDirectoryStructure(args.project_name)
    else:
        print("Invalid project type specified.")
        exit(1)

    project.create_directory_structure()
    print("Project structure created successfully.")
