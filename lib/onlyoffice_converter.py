import os
import subprocess
import logging

logger = logging.getLogger(__name__)

def convert_with_onlyoffice(pptx_path: str) -> str | None:
    """
    Converts PPTX to PDF using OnlyOffice document builder.

    Args:
        pptx_path (str): Path to the PPTX file

    Returns:
        str: Path to the generated PDF file, or None if conversion failed
    """
    pdf_path = pptx_path.rsplit('.', 1)[0] + '.pdf'

    env = os.environ.copy()
    env['LC_ALL'] = 'C.UTF-8'
    env['LANG'] = 'C.UTF-8'

    script_content = f'''
    builder.OpenFile("{pptx_path}");
    builder.SaveFile("pdf", "{pdf_path}");
    builder.CloseFile();
    '''
    script_path = os.path.join(os.path.dirname(pptx_path), 'convert.js')
    with open(script_path, 'w') as f:
        f.write(script_content)

    try:
        cmd = ['documentbuilder', script_path]
        process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=env)
        stdout, stderr = process.communicate()

        if process.returncode == 0 and os.path.exists(pdf_path):
            return pdf_path
        else:
            logger.error(f"Conversion failed: {stderr.decode()}")
            return None
    finally:
        try:
            os.remove(script_path)
        except Exception as e:
            logger.warning(f"Could not delete script file: {e}")
