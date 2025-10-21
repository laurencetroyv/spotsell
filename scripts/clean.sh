#!/bin/bash

# SpotSell Flutter Project Clean Script
# This script performs a complete clean and rebuild of the Flutter project

set -e  # Exit on any error

echo "🧹 Starting SpotSell project cleanup..."
echo "=================================="

# Step 1: Flutter clean
echo "📱 Running flutter clean..."
flutter clean
if [ $? -eq 0 ]; then
    echo "✅ Flutter clean completed successfully"
else
    echo "❌ Flutter clean failed"
    exit 1
fi

echo ""

# Step 2: Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get
if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi

echo ""

# Step 3: Clean build runner cache
echo "🔧 Cleaning build_runner cache..."
dart run build_runner clean
if [ $? -eq 0 ]; then
    echo "✅ Build runner cache cleaned successfully"
else
    echo "❌ Failed to clean build runner cache"
    exit 1
fi

echo ""

# Step 4: Run build runner with conflict resolution
echo "⚡ Running build_runner code generation..."
dart run build_runner build --delete-conflicting-outputs
if [ $? -eq 0 ]; then
    echo "✅ Code generation completed successfully"
else
    echo "❌ Code generation failed"
    exit 1
fi

echo ""
echo "🎉 SpotSell project cleanup completed successfully!"
echo "✨ Your project is ready for development"
echo "=================================="