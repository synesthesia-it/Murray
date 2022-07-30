# Configuration variables:
.DEFAULT_GOAL := build

# Prepare Application workspace

build: 
	swift build -c release
	cp -f .build/release/Murray /usr/local/bin/murray

project:
	swift package generate-xcodeproj

# Install dependencies, download build resources and add pre-commit hook

lint:
	swiftformat ./Sources
	swiftlint --fix
	swiftlint lint 
  
git_setup:
	eval "$$add_pre_commit_script"
  
setup:
	brew update && brew bundle
	make git_setup
	make project

# Define pre commit script to auto lint and format the code
define _add_pre_commit
if [ -d ".git" ]; then
SWIFTLINT_PATH=`which swiftlint`
SWIFTFORMAT_PATH=`which swiftformat`

cat > .git/hooks/pre-commit << ENDOFFILE
#!/bin/sh

FILES=\$(git diff --cached --name-only --diff-filter=ACMR "*.swift" | sed 's| |\\ |g')
[ -z "\$FILES" ] && exit 0

# Format
${SWIFTFORMAT_PATH} \$FILES

# Lint
${SWIFTLINT_PATH} --fix \$FILES
${SWIFTLINT_PATH} lint \$FILES

# Add back the formatted/linted files to staging
echo "\$FILES" | xargs git add

exit 0
ENDOFFILE

chmod +x .git/hooks/pre-commit
fi
endef
export add_pre_commit_script = $(value _add_pre_commit)


