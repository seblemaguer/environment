#!/usr/bin/python3

import argparse
from pathlib import Path
from typing import Union


class LectureOrgFile:
    """Class to handle creation of org-mode files for lecture materials."""

    def __init__(self, file_path: Union[str, Path]):
        self.file_path = file_path

    def create_file(self, title: str, content: str = "") -> None:
        """Create an org-mode file with specified title, content, and template."""
        with open(self.file_path, "w") as f:
            f.write(f"#+TITLE: {title}\n\n")
            if content:
                f.write(content)


class LectureDirectoryGenerator:
    """Class to handle creation of directory structure for organizing lecture materials."""

    def __init__(self, lecture_name: str):
        self.lecture_name = lecture_name.replace(" ", "_")
        self.root_dir = Path(self.lecture_name)

    def generate_directory(self) -> None:
        """Create directory structure and org-mode files."""
        self.root_dir.mkdir(exist_ok=True)

        readme_content = self._get_readme_content()
        readme_file = LectureOrgFile(self.root_dir / "README.org")
        readme_file.create_file("README", content=readme_content)

        for directory, contents in self._get_directory_structure().items():
            dir_path = self.root_dir / directory
            dir_path.mkdir(exist_ok=True)

            for title, content in contents.items():
                file_path = dir_path / f"{title}.org"
                org_file = LectureOrgFile(file_path)
                org_file.create_file(title, content=content)

        print(f"Directory '{self.root_dir}' created.")

    def _get_readme_content(self) -> str:
        """Return content for README file."""
        introduction_content = """
* TODO Lecture Objectives

This lecture aims to provide students with a foundational understanding of the topic at hand.
By the end of the lecture, students should be able to:
  - Understand the key concepts and principles underlying the topic.
  - Identify the applications and real-world relevance of the topic.
  - Apply critical thinking skills to analyze and evaluate related issues or challenges.
  - Engage in informed discussions and contribute to further exploration of the topic.

* TODO Overview of the Lecture

The lecture will cover a range of topics to provide a comprehensive understanding of the subject matter, including:
  - Introduction to the Topic: An overview of the history, significance, and context of the topic.
  - Core Concepts and Principles: Exploring fundamental concepts, theories, and models related to the topic.
  - Applications and Case Studies: Examining practical applications, case studies, or examples that illustrate the relevance and impact of the topic.
  - Current Trends and Future Directions: Discussing recent developments, emerging trends, and potential future directions in the field.
  - Interactive Activities and Discussions: Engaging in interactive activities, discussions, or exercises to deepen understanding and facilitate peer learning.

* TODO Pre-reading

To prepare for the lecture, you may find it helpful to:
  - Read introductory articles, chapters, or online resources related to the topic.
  - Explore multimedia content such as videos, podcasts, or documentaries to gain additional insights.
  - Reflect on personal experiences or observations relevant to the topic to enrich your understanding.
"""
        return introduction_content

    def _get_directory_structure(self) -> dict:
        """Return directory structure with templates."""
        directory_structure = {
            "Slides": {},
            "Handouts": {
                "Handout 1": "* Handout Content\n\nInsert handout content here.\n"
            },
            "References": {},
            "Examples": {},
            "Exercises": {},
            "Additional Resources": {},
            "Feedback and Evaluation": {
                "Feedback form": "* How satisfied are you with the lecture?\n* What aspects of the lecture did you find most useful?\n* What suggestions do you have for improvement?\n"
            },
            "Admin": {
                "Attendance sheets": "| Date       | Student Name    | Status |\n|------------+-----------------+--------|\n| yyyy-mm-dd | First Last      | Present|\n",
                "Grading rubrics": "Insert grading rubric here.\n\n* Example\n\nHere's an example of how the grading rubric can be filled out:\n\n| Criteria        | Points |\n|-----------------+--------|\n| Correctness     |   10   |\n| Completeness    |   5    |\n| Clarity         |   5    |\n",
                "Lecture schedule": "Insert lecture schedule here.\n\n* Example\n\nHere's an example of how the lecture schedule can be filled out:\n\n| Date       | Topic            |\n|------------+------------------|\n| 2024-03-15 | Introduction     |\n| 2024-03-22 | Main Topic 1     |\n| 2024-03-29 | Main Topic 2     |\n",
            },
            "Miscellaneous": {},
        }
        return directory_structure


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Create a directory structure for organizing lecture materials in org-mode."
    )
    parser.add_argument("lecture_name", type=str, help="Name of the lecture or course.")
    args = parser.parse_args()

    directory_generator = LectureDirectoryGenerator(args.lecture_name)
    directory_generator.generate_directory()
