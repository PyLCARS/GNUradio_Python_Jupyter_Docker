#!/opt/venv/bin/python
"""
Comprehensive build verification script for GNU Radio Jupyter Docker.
Runs during Docker build and fails the build if any test fails.
"""

import sys
import json
import subprocess
from pathlib import Path

# Colors for output
GREEN = '\033[92m'
RED = '\033[91m'
YELLOW = '\033[93m'
BLUE = '\033[94m'
RESET = '\033[0m'

def print_test(name, status, message=""):
    """Print test result with color"""
    symbol = "✓" if status else "✗"
    color = GREEN if status else RED
    print(f"{color}{symbol} {name}{RESET}")
    if message and not status:
        print(f"  {RED}→ {message}{RESET}")
    return status

def test_python_version():
    """Verify Python version"""
    version = sys.version_info
    expected_major = 3
    expected_minor = 12
    
    passed = version.major == expected_major and version.minor >= expected_minor
    return print_test(
        f"Python version ({version.major}.{version.minor})",
        passed,
        f"Expected Python {expected_major}.{expected_minor}+"
    )

def test_numpy_version():
    """Verify NumPy version is 1.x (required for GNU Radio)"""
    try:
        import numpy as np
        version = np.__version__
        major_version = int(version.split('.')[0])
        passed = major_version == 1
        return print_test(
            f"NumPy version ({version})",
            passed,
            "GNU Radio requires NumPy 1.x, not 2.x"
        )
    except ImportError as e:
        return print_test("NumPy import", False, str(e))

def test_gnu_radio():
    """Verify GNU Radio is accessible and functional"""
    try:
        # Add GNU Radio to path
        sys.path.append('/usr/lib/python3/dist-packages')
        
        # Import GNU Radio
        from gnuradio import gr
        from gnuradio import blocks
        from gnuradio import analog
        
        # Create a simple flowgraph
        tb = gr.top_block()
        src = analog.sig_source_c(32000, analog.GR_COS_WAVE, 1000, 1, 0)
        head = blocks.head(gr.sizeof_gr_complex, 100)
        sink = blocks.vector_sink_c()
        
        tb.connect(src, head, sink)
        tb.run()
        
        data = sink.data()
        passed = len(data) == 100
        
        return print_test(
            f"GNU Radio {gr.version()}",
            passed,
            f"Expected 100 samples, got {len(data)}"
        )
    except Exception as e:
        return print_test("GNU Radio functionality", False, str(e))

def test_jupyter():
    """Verify Jupyter is installed and functional"""
    try:
        import notebook
        import jupyterlab
        import ipykernel
        
        # Check if jupyter command exists
        result = subprocess.run(
            ["/opt/venv/bin/jupyter", "--version"],
            capture_output=True,
            text=True
        )
        
        passed = result.returncode == 0
        return print_test(
            f"Jupyter Lab {jupyterlab.__version__}",
            passed,
            result.stderr if not passed else ""
        )
    except Exception as e:
        return print_test("Jupyter installation", False, str(e))

def test_template_system():
    """Verify template system is properly configured"""
    try:
        # Check if config file exists
        config_path = Path("/home/jovyan/.jupyter/jupyter_notebook_config.py")
        if not config_path.exists():
            return print_test("Template config", False, "Config file not found")
        
        # Check if base template exists
        template_path = Path("/home/jovyan/.jupyter/templates/gnuradio_base_template.json")
        if not template_path.exists():
            return print_test("Base template", False, "Template file not found")
        
        # Verify template is valid JSON
        with open(template_path, 'r') as f:
            template = json.load(f)
        
        # Check template structure
        has_cells = 'cells' in template
        has_metadata = 'metadata' in template
        cells_count = len(template.get('cells', []))
        
        passed = has_cells and has_metadata and cells_count > 0
        return print_test(
            f"Template system ({cells_count} cells)",
            passed,
            "Invalid template structure" if not passed else ""
        )
    except Exception as e:
        return print_test("Template system", False, str(e))

def test_critical_packages():
    """Test all critical package imports"""
    packages = [
        ('matplotlib', 'matplotlib'),
        ('scipy', 'scipy'),
        ('pandas', 'pandas'),
        ('plotly', 'plotly'),
        ('loguru', 'loguru'),
        ('toml', 'toml'),
        ('ipywidgets', 'ipywidgets'),
    ]
    
    all_passed = True
    for name, import_name in packages:
        try:
            module = __import__(import_name)
            # Get version if available
            version = getattr(module, '__version__', 'unknown')
            print_test(f"Package: {name} ({version})", True)
        except ImportError as e:
            print_test(f"Package: {name}", False, str(e))
            all_passed = False
    
    return all_passed

def test_pyproject_dependencies():
    """Verify all pyproject.toml dependencies are installed"""
    try:
        import toml
        
        # Load pyproject.toml if it exists
        pyproject_path = Path("/tmp/pyproject.toml")
        if not pyproject_path.exists():
            # Try other locations
            for alt_path in [
                Path("/home/jovyan/pyproject.toml"),
                Path("/home/jovyan/notebooks/pyproject.toml"),
            ]:
                if alt_path.exists():
                    pyproject_path = alt_path
                    break
        
        if pyproject_path.exists():
            with open(pyproject_path, 'r') as f:
                config = toml.load(f)
            
            # Get dependencies
            deps = config.get('project', {}).get('dependencies', [])
            
            print(f"{BLUE}Checking {len(deps)} dependencies from pyproject.toml...{RESET}")
            
            # For each dependency, try to extract package name and verify
            all_passed = True
            for dep in deps:
                # Extract package name (before any version specifier)
                pkg_name = dep.split('[')[0].split('>')[0].split('<')[0].split('=')[0].strip()
                
                # Map package names to import names
                import_map = {
                    'scikit-rf': 'skrf',
                    'scikit-learn': 'sklearn',
                    'pillow': 'PIL',
                    'msgpack-python': 'msgpack',
                }
                import_name = import_map.get(pkg_name, pkg_name.replace('-', '_'))
                
                try:
                    __import__(import_name)
                    print_test(f"  {pkg_name}", True)
                except ImportError:
                    print_test(f"  {pkg_name}", False, "Not installed")
                    all_passed = False
            
            return all_passed
        else:
            print(f"{YELLOW}No pyproject.toml found to verify{RESET}")
            return True
            
    except Exception as e:
        return print_test("pyproject.toml dependencies", False, str(e))

def test_permissions():
    """Verify file permissions are correct"""
    paths_to_check = [
        Path("/home/jovyan"),
        Path("/home/jovyan/.jupyter"),
        Path("/home/jovyan/notebooks"),
        Path("/opt/venv"),
    ]
    
    import os
    import pwd
    
    all_passed = True
    for path in paths_to_check:
        if path.exists():
            stat_info = os.stat(path)
            try:
                owner = pwd.getpwuid(stat_info.st_uid).pw_name
            except KeyError:
                owner = f"UID:{stat_info.st_uid}"
            
            # Accept either jovyan or the UID 1001 (or whatever was used)
            passed = owner == 'jovyan' or stat_info.st_uid >= 1000
            if not print_test(f"Permissions: {path}", passed, f"Owner is {owner}"):
                all_passed = False
    
    return all_passed

def test_ipython_startup():
    """Verify IPython startup script is in place"""
    try:
        startup_path = Path("/home/jovyan/.ipython/profile_default/startup/00-gnuradio-bridge.py")
        
        if not startup_path.exists():
            return print_test("IPython startup", False, "Startup script not found")
        
        # Check if it contains GNU Radio bridge code
        with open(startup_path, 'r') as f:
            content = f.read()
        
        has_gnuradio = 'gnuradio' in content
        has_path = '/usr/lib/python3/dist-packages' in content
        
        passed = has_gnuradio and has_path
        return print_test(
            "IPython GNU Radio bridge",
            passed,
            "Missing GNU Radio setup in startup script" if not passed else ""
        )
    except Exception as e:
        return print_test("IPython startup", False, str(e))

def test_jupyter_kernel():
    """Verify Jupyter kernel is properly configured"""
    try:
        # Check if kernel spec exists
        kernel_path = Path("/opt/venv/share/jupyter/kernels/python3")
        
        if not kernel_path.exists():
            return print_test("Jupyter kernel", False, "Kernel spec not found")
        
        kernel_json = kernel_path / "kernel.json"
        if not kernel_json.exists():
            return print_test("Jupyter kernel", False, "kernel.json not found")
        
        with open(kernel_json, 'r') as f:
            kernel_spec = json.load(f)
        
        # Check display name
        display_name = kernel_spec.get('display_name', '')
        has_gnu_radio = 'GNU Radio' in display_name
        
        return print_test(
            f"Jupyter kernel ({display_name})",
            has_gnu_radio,
            "Kernel not configured for GNU Radio" if not has_gnu_radio else ""
        )
    except Exception as e:
        return print_test("Jupyter kernel", False, str(e))

def test_uv_package_manager():
    """Verify UV package manager is installed"""
    try:
        result = subprocess.run(
            ["/opt/venv/bin/uv", "--version"],
            capture_output=True,
            text=True
        )
        
        passed = result.returncode == 0
        if passed:
            version = result.stdout.strip()
            return print_test(f"UV package manager ({version})", True)
        else:
            return print_test("UV package manager", False, "UV not found or not working")
    except FileNotFoundError:
        return print_test("UV package manager", False, "UV binary not found")
    except Exception as e:
        return print_test("UV package manager", False, str(e))

def main():
    """Run all tests and exit with appropriate code"""
    print(f"\n{BLUE}{'='*60}{RESET}")
    print(f"{BLUE}GNU Radio Jupyter Docker - Build Verification{RESET}")
    print(f"{BLUE}{'='*60}{RESET}\n")
    
    tests = [
        ("Python Environment", test_python_version),
        ("NumPy Compatibility", test_numpy_version),
        ("GNU Radio", test_gnu_radio),
        ("Jupyter", test_jupyter),
        ("Jupyter Kernel", test_jupyter_kernel),
        ("Template System", test_template_system),
        ("IPython Startup", test_ipython_startup),
        ("Critical Packages", test_critical_packages),
        ("Project Dependencies", test_pyproject_dependencies),
        ("UV Package Manager", test_uv_package_manager),
        ("File Permissions", test_permissions),
    ]
    
    results = {}
    for test_name, test_func in tests:
        print(f"\n{YELLOW}Testing {test_name}...{RESET}")
        results[test_name] = test_func()
    
    # Summary
    print(f"\n{BLUE}{'='*60}{RESET}")
    print(f"{BLUE}Summary{RESET}")
    print(f"{BLUE}{'='*60}{RESET}\n")
    
    passed = sum(1 for v in results.values() if v)
    total = len(results)
    
    if passed == total:
        print(f"{GREEN}✓ All {total} tests passed!{RESET}")
        print(f"{GREEN}Build verification successful.{RESET}\n")
        print(f"{GREEN}Docker image is ready for use.{RESET}")
        sys.exit(0)
    else:
        print(f"{RED}✗ {total - passed} of {total} tests failed!{RESET}")
        print(f"{RED}Build verification failed.{RESET}\n")
        print(f"{RED}Failed tests:{RESET}")
        for name, result in results.items():
            if not result:
                print(f"  {RED}• {name}{RESET}")
        print(f"\n{RED}Please fix the issues and rebuild.{RESET}")
        sys.exit(1)

if __name__ == "__main__":
    main()
