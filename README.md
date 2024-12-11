# quotes

A Quotes Flutter project.

## Getting Started with make files
Let me break down the key aspects of this Makefile:
Purpose:

Automates common development tasks across packages and features
Provides commands for dependency management, testing, cleaning, and build runners

Key Commands:

make get: Fetches dependencies for all packages and features
make upgrade: Upgrades dependencies
make lint: Runs Flutter analyze
make testing: Runs tests for all packages and features
make clean: Cleans Flutter projects
make build-runner: Runs build_runner for specific packages
make pods-clean: Removes iOS-related files and pods

Notable Characteristics:

Uses wildcard to dynamically discover packages and features
Loops through packages and features to perform operations
Separates build-runner packages explicitly
Supports comprehensive project-wide operations

This Makefile provides a robust workflow management tool for a modular Flutter project with multiple packages and features.

## Working with APIs
Storing your API Keys in a compile-time variable
- Just run the following command
`flutter run --dart-define=fav-qs-app-token=YOUR_KEY`