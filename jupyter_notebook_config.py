#!/usr/bin/env python3
"""
Jupyter configuration with GNU Radio template system.
This config file is loaded by JupyterLab at startup.
"""

import os
import sys
import json
import logging
from pathlib import Path

# Configure logging to see what's happening
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Get the config object
c = get_config()

# Use the correct import for newer Jupyter versions
from jupyter_server.services.contents.largefilemanager import LargeFileManager

class GNURadioTemplateManager(LargeFileManager):
    """
    Custom ContentsManager that applies GNU Radio templates to new notebooks.
    Inherits from LargeFileManager to maintain all default functionality.
    """
    
    def new_untitled(self, path='', type='', ext=''):
        """Override notebook creation to apply templates"""
        
        # Only apply template to notebooks
        if type != 'notebook':
            return super().new_untitled(path=path, type=type, ext=ext)
        
        print(f"GNURadioTemplateManager: Creating new notebook at path: {path}", file=sys.stderr)
        logger.info(f"GNURadioTemplateManager: Creating new notebook at path: {path}")
        
        # Create the notebook using parent method first
        model = super().new_untitled(path=path, type=type, ext=ext)
        
        # Load our template
        template_path = Path('/home/jovyan/.jupyter/templates/gnuradio_base_template.json')
        
        if template_path.exists():
            try:
                with open(template_path, 'r') as f:
                    template_content = json.load(f)
                
                # Get the full file path
                notebook_path = model['path']
                full_path = os.path.join(self.root_dir, notebook_path)
                
                # Add missing id fields to cells to avoid warnings
                import uuid
                for cell in template_content.get('cells', []):
                    if 'id' not in cell:
                        cell['id'] = str(uuid.uuid4())
                
                # Write the template content directly to the file
                import nbformat
                nb = nbformat.from_dict(template_content)
                nbformat.write(nb, full_path)
                
                print(f"Successfully applied GNU Radio template to {model['name']}", file=sys.stderr)
                logger.info(f"Successfully applied GNU Radio template to {model['name']}")
                
                # IMPORTANT: Set content to None so Jupyter will read it from disk
                model['content'] = None
                
            except Exception as e:
                print(f"Failed to apply template: {e}", file=sys.stderr)
                logger.error(f"Failed to apply template: {e}")
                import traceback
                traceback.print_exc()
        else:
            print(f"Template not found at {template_path}", file=sys.stderr)
            logger.warning(f"Template not found at {template_path}")
        
        return model

# Apply our custom ContentsManager to JupyterLab
c.ServerApp.contents_manager_class = GNURadioTemplateManager

# Additional JupyterLab settings
c.ServerApp.open_browser = False

# Log that config was loaded
print("GNU Radio template system configured successfully!", file=sys.stderr)
logger.info("GNU Radio template configuration loaded successfully")
