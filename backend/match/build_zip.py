"""
Build script to package AWS Lambda function.
Creates function.zip containing exactly lambda_function.py and phrases.json.
"""

import os
import zipfile

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ZIP_NAME = "function.zip"
ZIP_PATH = os.path.join(SCRIPT_DIR, ZIP_NAME)

REQUIRED_FILES = [
    "lambda_function.py",
    "phrases.json",
]


def build_lambda_zip() -> None:
    print(f"Building {ZIP_NAME} in {SCRIPT_DIR}...")

    # Validate that all required files exist
    for filename in REQUIRED_FILES:
        filepath = os.path.join(SCRIPT_DIR, filename)
        if not os.path.isfile(filepath):
            raise FileNotFoundError(f"Required file missing: {filepath}")

    # Remove existing zip if present
    if os.path.exists(ZIP_PATH):
        os.remove(ZIP_PATH)
        print(f"Removed previous {ZIP_NAME}")

    # Create zip archive with standard DEFLATED compression
    with zipfile.ZipFile(ZIP_PATH, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        for filename in REQUIRED_FILES:
            filepath = os.path.join(SCRIPT_DIR, filename)
            zf.write(filepath, arcname=filename)
            print(f"  + Added: {filename} ({os.path.getsize(filepath)} bytes)")

    # Verify zip archive contents
    with zipfile.ZipFile(ZIP_PATH, "r") as zf:
        archive_members = sorted(zf.namelist())
        expected_members = sorted(REQUIRED_FILES)

        if archive_members != expected_members:
            raise ValueError(
                f"Zip archive content mismatch!\nExpected: {expected_members}\nFound: {archive_members}"
            )

        print("\nZip verification successful:")
        for info in zf.infolist():
            print(f"  - {info.filename:20} -> {info.file_size:6} bytes (compressed: {info.compress_size:6} bytes)")

    print(f"\nArtifact ready: {ZIP_PATH} ({os.path.getsize(ZIP_PATH)} bytes)")


if __name__ == "__main__":
    build_lambda_zip()
