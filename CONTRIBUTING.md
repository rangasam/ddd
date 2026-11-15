# Contributing to Docker Deep Dive

Thank you for your interest in contributing to Docker Deep Dive! This guide will help you get started.

## How to Contribute

### Reporting Issues

If you find a bug or have a suggestion:

1. Check if the issue already exists in the [Issues](https://github.com/rangasam/ddd/issues) section
2. If not, create a new issue with:
   - A clear title
   - Detailed description
   - Steps to reproduce (for bugs)
   - Your environment details (OS, Docker version, etc.)

### Submitting Changes

1. **Fork the Repository**
   ```bash
   gh repo fork rangasam/ddd
   ```

2. **Clone Your Fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/ddd.git
   cd ddd
   ```

3. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. **Make Your Changes**
   - Keep changes focused and minimal
   - Follow existing code style
   - Test your changes thoroughly

5. **Test Your Changes**
   ```bash
   docker compose config --quiet  # Validate syntax
   docker compose up -d           # Test the setup
   docker compose down -v         # Clean up
   ```

6. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "Description of your changes"
   ```

7. **Push to Your Fork**
   ```bash
   git push origin feature/your-feature-name
   ```

8. **Create a Pull Request**
   - Go to the original repository
   - Click "New Pull Request"
   - Select your branch
   - Provide a clear description of your changes

## Development Guidelines

### Docker Compose

- Use environment variables for configuration
- Provide sensible defaults
- Add comments for complex configurations
- Test with both Docker Compose v1 and v2

### Documentation

- Update README.md for significant changes
- Keep examples simple and clear
- Include troubleshooting tips
- Update QUICKSTART.md if setup process changes

### Environment Variables

- Add new variables to `.env.example`
- Document their purpose in README.md
- Use `${VAR:-default}` syntax for defaults

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Provide constructive feedback
- Focus on collaboration

## Questions?

Feel free to open an issue for any questions about contributing!

## License

By contributing, you agree that your contributions will be licensed under the GNU General Public License v3.0.
