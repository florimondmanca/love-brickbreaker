"""
Run this script above the src/ folder to zip the game into an app.love file
and run app.love.
Usage: `$ python3 makelove.py`
"""

if __name__ == '__main__':
    import os
    import sys
    from subprocess import run

    shell = os.getenv('SHELL')
    kind = len(sys.argv) >= 2 and sys.argv[1] or 'game'

    run([shell, '-i', '-c',
         """cd src/{kind}; zip -r ../../{kind}.love *; cd ../..;
         love {kind}.love""".format(kind=kind)])
