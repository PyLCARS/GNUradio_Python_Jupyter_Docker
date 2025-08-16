# Contributing to GNU Radio Jupyter Docker

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Development Setup

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd GNU_Radio_Jupyter_Python_Docker
   ```

2. **Build and test**
   ```bash
   ./gnuradio_jupyter_docker_manager.sh build
   ./gnuradio_jupyter_docker_manager.sh verify
   ```

## Making Changes

### Critical Constraints

Before making any changes, understand these **non-negotiable constraints**:

1. **NumPy 1.x Requirement**: GNU Radio requires NumPy 1.x. Never update to NumPy 2.x
2. **Virtual Environment Isolation**: Never use `--system-site-packages` in venv creation
3. **Docker Layer Optimization**: Maintain the current layer structure for fast rebuilds

### Types of Contributions

**Template System Changes**
- Edit `config/pyproject.toml` under `[tool.jupyter]` sections
- No rebuild required - test by creating new notebooks
- Document changes in commit message

**Dependency Changes**
- Edit `config/pyproject.toml` dependencies section
- Must maintain NumPy 1.x constraint and related version locks
- Rebuild and verify: `./gnuradio_jupyter_docker_manager.sh rebuild && ./gnuradio_jupyter_docker_manager.sh verify`

**Docker Build Changes**
- Edit `docker/Dockerfile`
- Maintain layer optimization strategy
- Test thoroughly with verification suite

**Management Script Changes**
- Edit `gnuradio_jupyter_docker_manager.sh`
- Test all script functions before submitting
- Known issue: duplicate function definitions should be cleaned up

## Testing Requirements

Before submitting any PR:

1. **Build Verification**
   ```bash
   ./gnuradio_jupyter_docker_manager.sh rebuild
   ./gnuradio_jupyter_docker_manager.sh verify
   ```

2. **Functionality Tests**
   ```bash
   ./gnuradio_jupyter_docker_manager.sh test
   ```

3. **Template System Test**
   - Start container
   - Create new notebook
   - Verify GNU Radio imports work
   - Verify template content is applied

## Submitting Changes

### Pull Request Process

1. **Create feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Follow existing code style
   - Maintain backward compatibility
   - Add/update documentation as needed

3. **Test thoroughly**
   - Run full verification suite
   - Test on clean Docker environment

4. **Submit PR**
   - Clear description of changes
   - Reference any related issues
   - Include test results

### Commit Message Format

```
type: brief description

Detailed explanation of changes made and why.

- Specific change 1
- Specific change 2

Tested with:
- ./gnuradio_jupyter_docker_manager.sh verify
- Template system functionality
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## Common Development Tasks

### Adding New Python Package
1. Add to `config/pyproject.toml` dependencies
2. Check version constraints (especially NumPy compatibility)
3. Rebuild and verify
4. Test in notebook

### Modifying Templates
1. Edit `config/pyproject.toml` under `[tool.jupyter]`
2. Test with new notebook creation
3. Document changes

### Docker Optimization
1. Understand current layer strategy
2. Make changes while preserving cache efficiency
3. Test build times before/after

## Issue Reporting

Use GitHub issue templates:
- **Bug Report**: For problems with existing functionality
- **Feature Request**: For new feature suggestions

Include:
- Environment details (OS, Docker version)
- Command output and error messages
- Steps to reproduce

## Code Style

- **Shell scripts**: Follow existing style in management script
- **Dockerfile**: Maintain layer comments and optimization
- **Python**: Follow PEP 8 (when applicable)
- **Documentation**: Clear, concise, practical

## Getting Help

- Review existing issues and discussions
- Check `CLAUDE.md` for development context
- Test with verification suite
- Ask questions in issues with `question` label

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.