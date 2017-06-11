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
    titles = {'editor': 'BrickBreakerEditor', 'game': 'BrickBreaker'}
    kind = len(sys.argv) >= 2 and sys.argv[1] or 'game'

    run([shell, '-i', '-c',
         """cd src/{kind}; zip -r ../../{title}.love *; cd ../..;
         love {title}.love""".format(kind=kind, title=titles[kind])])
