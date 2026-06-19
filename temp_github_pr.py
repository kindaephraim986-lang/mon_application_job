import base64
import json
import os
import pathlib
import urllib.error
import urllib.request

TOKEN = os.environ.get('GITHUB_TOKEN')
if not TOKEN:
    raise SystemExit('Missing GITHUB_TOKEN')

OWNER = 'kindaephraim986-lang'
REPO = 'mon_application_job'
NEW_BRANCH = 'add-dockerfile-from-main'
BASE_BRANCH = 'main'
FILE_PATH = 'Dockerfile'
COMMIT_MESSAGE = 'Add root Dockerfile for Render deployment'
PR_TITLE = 'Add Dockerfile for Render deployment'
PR_BODY = 'Adds root Dockerfile to enable Render Docker builds on Render.com.'

headers = {
    'Authorization': f'token {TOKEN}',
    'Accept': 'application/vnd.github.v3+json',
    'User-Agent': 'GitHub-API-Client'
}

base_ref_url = f'https://api.github.com/repos/{OWNER}/{REPO}/git/ref/heads/{BASE_BRANCH}'


def github_request(method, url, body=None):
    data = None
    if body is not None:
        data = json.dumps(body).encode('utf-8')
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req) as r:
            return json.load(r)
    except urllib.error.HTTPError as e:
        content = e.read().decode('utf-8')
        try:
            err = json.loads(content)
        except Exception:
            err = {'message': content}
        raise SystemExit(f'GitHub API error {e.code}: {err}')


def ensure_branch():
    ref_url = f'https://api.github.com/repos/{OWNER}/{REPO}/git/ref/heads/{NEW_BRANCH}'
    try:
        data = github_request('GET', ref_url)
        print('Branch already exists:', data['ref'])
        return data['object']['sha']
    except SystemExit as e:
        if '404' not in str(e):
            raise
    base_data = github_request('GET', base_ref_url)
    base_sha = base_data['object']['sha']
    print('Creating branch', NEW_BRANCH, 'from', BASE_BRANCH, base_sha)
    create_body = {'ref': f'refs/heads/{NEW_BRANCH}', 'sha': base_sha}
    branch_data = github_request('POST', f'https://api.github.com/repos/{OWNER}/{REPO}/git/refs', create_body)
    return branch_data['object']['sha']


def ensure_file_in_branch():
    path = pathlib.Path(FILE_PATH)
    if not path.exists():
        raise SystemExit(f'Local file not found: {FILE_PATH}')
    content = path.read_bytes()
    encoded = base64.b64encode(content).decode('utf-8')
    file_url = f'https://api.github.com/repos/{OWNER}/{REPO}/contents/{FILE_PATH}'
    body = {
        'message': COMMIT_MESSAGE,
        'content': encoded,
        'branch': NEW_BRANCH
    }
    try:
        existing = github_request('GET', f'{file_url}?ref={NEW_BRANCH}')
        body['sha'] = existing['sha']
        print('Updating existing file in branch:', FILE_PATH)
    except SystemExit as e:
        if '404' in str(e):
            print('Creating new file in branch:', FILE_PATH)
        else:
            raise
    github_request('PUT', file_url, body)


def find_or_create_pr():
    query = f'https://api.github.com/repos/{OWNER}/{REPO}/pulls?state=open&head={OWNER}:{NEW_BRANCH}&base={BASE_BRANCH}'
    prs = github_request('GET', query)
    if prs:
        pr = prs[0]
        print('Existing open PR found:', pr['number'], pr['html_url'])
        return pr['number']
    body = {
        'title': PR_TITLE,
        'head': NEW_BRANCH,
        'base': BASE_BRANCH,
        'body': PR_BODY
    }
    pr = github_request('POST', f'https://api.github.com/repos/{OWNER}/{REPO}/pulls', body)
    print('Created PR:', pr['number'], pr['html_url'])
    return pr['number']


def merge_pr(pr_num):
    merge_url = f'https://api.github.com/repos/{OWNER}/{REPO}/pulls/{pr_num}/merge'
    body = {
        'commit_title': f'Merge {NEW_BRANCH} into {BASE_BRANCH}',
        'merge_method': 'merge'
    }
    result = github_request('PUT', merge_url, body)
    print('Merged:', result.get('merged'), result.get('message'))


if __name__ == '__main__':
    ensure_branch()
    ensure_file_in_branch()
    pr_number = find_or_create_pr()
    merge_pr(pr_number)
