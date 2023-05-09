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

def make_fetch(dist):
    modules = subprocess.check_output(['make', 'list'], cwd=TOPDIR).decode().splitlines()
    mlen    = max([len(i) for i in modules])
    print(f"[{dist}] fetch {' ' * mlen}", end='\r', flush=True)
    start = datetime.datetime.now()
    r = subprocess.run(['make',
                        '--output-sync=recurse',
                        f'DEBDIST={dist}',
                        'fetch'],
                        cwd=TOPDIR,
                        stdout=subprocess.PIPE,
                        stderr=subprocess.STDOUT)
    end = datetime.datetime.now()
    status = (r.returncode == 0)
    log_status(f"[{dist}] fetch {' ' * mlen}",status, end-start)
    if not status:
            tmp_log = r.stdout.decode().splitlines()
            with(open(f"{TOPDIR}/out/{dist}-fetch-fail.log", "w")) as f:
                f.write('\n'.join(tmp_log))
            print('\n'.join(tmp_log[-10:]))
            raise Exception("Fetch fail cannot test less source code")

def test(stage, dist, scratch):
    modules = subprocess.check_output(['make', 'list'], cwd=TOPDIR).decode().splitlines()
    mlen    = max([len(i) for i in modules])
    if stage == 'check-final':
        modules = [m for m in modules if 'final' in m]
        modules = [f"check-{m}" for m in modules]
    else:
        modules = [m for m in modules if stage in m]

    for m in modules:
        print(f"[{dist}] build {m:{mlen}}", end='\r', flush=True)
        start = datetime.datetime.now()
        if scratch:
            clobber = 'clobber'
        elif stage == 'check-final':
            clobber = 'clobber-final'
        else:
            clobber = f'clobber-{stage}'
        
        subprocess.run(['make',
                        '--output-sync=recurse',
                        f'DEBDIST={dist}',
                        clobber],
                        cwd=TOPDIR,
                        stdout=subprocess.PIPE,
                        stderr=subprocess.STDOUT)
        r = subprocess.run(['make',
                            '--output-sync=recurse',
                            f'DEBDIST={dist}',
                            m],
                            cwd=TOPDIR,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT)
        end = datetime.datetime.now()
        status = (r.returncode == 0)
        log_status(f"[{dist}] build {m:{mlen}}",status, end-start)
        if not status:
            tmp_log = r.stdout.decode().splitlines()
            with(open(f"{TOPDIR}/out/{dist}-{m}-fail.log", "w")) as f:
                f.write('\n'.join(tmp_log))
            print('\n'.join(tmp_log[-10:]))

def main(dist, stage = None, fetch=False, scratch=False):
    global TEST_FAIL, TEST_OK, DOCKER_FROM
    TEST_FAIL, TEST_OK = 0, 0

    start = datetime.datetime.now()

    try:
        print(datetime.datetime.now().strftime("%A, %d. %B %Y %I:%M%p"))
        if fetch:
            make_fetch(dist)
        if stage:
            test(stage, dist, scratch)
        else:
            test('bstrap', dist, scratch)
            test('stage', dist, scratch)
            test('final', dist, scratch)
            test('check-final', dist, scratch)
    finally:
        end = datetime.datetime.now()
        print(f"Total in {end - start}:\n  OK  {TEST_OK:d}\n FAIL {TEST_FAIL:d}")

if __name__ == "__main__":
    import argparse

    dist = [x[:-3] for x in list(os.walk(f"{TOPDIR}/debian"))[0][2] if x.endswith('.mk')]
    dist.sort()

    parser = argparse.ArgumentParser(description='Test build deps')
    parser.add_argument('--stage', choices=['bstrap', 'stage', 'final', 'check-final'], help="limit test to specific stage")
    parser.add_argument('--dist', choices=dist, help="specify distribution used for test", default='bullseye')
    parser.add_argument('--fetch', action='store_true', help='fetch data')
    parser.add_argument('--scratch', action='store_true', help='clobber all before sub-test')
    args = parser.parse_args()
    main(stage = args.stage, dist = args.dist, fetch=args.fetch, scratch=args.scratch)