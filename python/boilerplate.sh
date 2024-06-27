#!/bin/bash

# Ask for the project name
read -p "Enter the project name: " project_name

# Create project directory
mkdir "$project_name"
cd "$project_name"

# Create main package directory
mkdir "$project_name"

# Create tests directory
mkdir tests

# Create main __init__.py
touch "$project_name/__init__.py"

# Create main.py
cat > "$project_name/main.py" << EOL
def main():
    print("Hello, World!")

if __name__ == "__main__":
    main()
EOL

# Create test_main.py
cat > "tests/test_main.py" << EOL
import unittest
from ${project_name}.main import main

class TestMain(unittest.TestCase):
    def test_main(self):
        # Add your test cases here
        self.assertTrue(True)

if __name__ == '__main__':
    unittest.main()
EOL

# Create requirements.txt
touch requirements.txt

# Create README.md
cat > README.md << EOL
# ${project_name}

Description of your project.

## Installation

\`\`\`
pip install -r requirements.txt
\`\`\`

## Usage

\`\`\`
python -m ${project_name}.main
\`\`\`

## Running Tests

\`\`\`
python -m unittest discover tests
\`\`\`
EOL

# Create .gitignore
cat > .gitignore << EOL
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# Virtual environment
venv/
env/

# IDE settings
.vscode/
.idea/

# Distribution / packaging
dist/
build/
*.egg-info/
EOL

# Initialize git repository
git init

echo "Python project '${project_name}' created successfully!"
echo "Project structure:"
tree -L 2
