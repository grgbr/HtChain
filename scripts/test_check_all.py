#!/usr/bin/env python3
import subprocess
import datetime
import os

TOPDIR=os.path.realpath(os.path.dirname(os.path.realpath(__file__)) + '/..')

COLOR_DEFAULT = "\033[0m"
COLOR_OK      = "\033[92m"
COLOR_FAIL    = "\033[91m"
COLOR_WARNING = "\033[93m"

def log_status(head, status, time):
    global TEST_FAIL, TEST_OK
    if status:
        TEST_OK += 1
    else:
        TEST_FAIL += 1
    print(head, f"{COLOR_OK}{time}{COLOR_DEFAULT}" if status else f"{COLOR_FAIL}{time}{COLOR_DEFAULT}")

def make(dist:str, tagrdet:str, mlen = 0) -> bool:
    print(f"[{dist}] {tagrdet:{mlen}}", end='\r', flush=True)
    start = datetime.datetime.now()
    r = subprocess.run(['make',
                        '--output-sync=recurse',
                        f'DEBDIST={dist}',
                        tagrdet],
                        cwd=TOPDIR,
                        stdout=subprocess.PIPE,
                        stderr=subprocess.STDOUT)
    end = datetime.datetime.now()
    status = (r.returncode == 0)
    log_status(f"[{dist}] {tagrdet:{mlen}}",status, end-start)
    if not status:
        tmp_log = r.stdout.decode().splitlines()
        with(open(f"{TOPDIR}/out/{dist}-{tagrdet}-fail.log", "w")) as f:
            f.write('\n'.join(tmp_log))
        return False
    return True

def main(dist, fetch=False, test_only=False, module_filter=[]):
    global TEST_FAIL, TEST_OK, DOCKER_FROM
    TEST_FAIL, TEST_OK = 0, 0

    start = datetime.datetime.now()

    modules = subprocess.check_output(['make', 'list'], cwd=TOPDIR).decode().splitlines()
    modules = [m for m in modules if 'final' in m]
    modules.append('final-rpath')
    modules.append('final-shebang')
    if module_filter:
        module_filter = [f"final-{m}" for m in module_filter]
        modules = [m for m in modules if m in module_filter]
    modules = [f"check-{m}" for m in modules]
    mlen    = max([len(i) for i in modules])
    try:
        print(datetime.datetime.now().strftime("%A, %d. %B %Y %I:%M%p"))
        if fetch:
            if not make(dist[0], 'fetch', mlen):
                raise Exception("Fetch fail cannot test less source code")
        for d in dist:
            if not test_only:
                if not make(d, 'clobber', mlen):
                    continue
                if not make(d, 'debian', mlen):
                    continue
            for m in modules:
                make(d, m, mlen)
    finally:
        end = datetime.datetime.now()
        print(f"Total in {end - start}:\n  OK  {TEST_OK:d}\n FAIL {TEST_FAIL:d}")

if __name__ == "__main__":
    import argparse

    dist = [x[:-3] for x in list(os.walk(f"{TOPDIR}/debian"))[0][2] if x.endswith('.mk')]
    dist.sort()

    parser = argparse.ArgumentParser(description='Test build deps')
    parser.add_argument('--fetch', action='store_true', help='fetch data')
    parser.add_argument('--test-only', action='store_true', help='no clobber and build before run tests')
    parser.add_argument('--dist', choices=dist, help="specify distribution used for tests", default=None)
    parser.add_argument('--module', action='append', help='select module to test')
    args = parser.parse_args()
    if args.dist:
        dist = [args.dist]
    main(dist, fetch=args.fetch, test_only=args.test_only, module_filter=args.module)