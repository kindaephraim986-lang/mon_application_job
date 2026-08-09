import json
from pathlib import Path

def load(path, encoding):
    data = Path(path).read_bytes()
    return json.loads(data.decode(encoding))

for fname, enc in [
    ('render_service.json','utf-16'),
    ('render_environments.json','utf-16'),
    ('render_deploys.json','utf-16'),
    ('render_logs.json','utf-16'),
]:
    print('===', fname)
    path = Path(fname)
    raw = path.read_bytes()
    print('len=', len(raw), 'bom=', raw[:4])
    try:
        data = json.loads(raw.decode(enc))
        print('parsed', type(data), len(data) if hasattr(data,'__len__') else 'n/a')
        if fname == 'render_service.json':
            service = data[0]['service']
            print('service.id=', service.get('id'))
            print('service.name=', service.get('name'))
            print('service.environmentId=', service.get('environmentId'))
            print('project.id=', data[0]['project'].get('id'))
            print('environment type=', type(data[0].get('environment')))
            print('environment keys=', list(data[0].get('environment', {}).keys()))
        if fname == 'render_environments.json':
            env = data[0]
            print('env.id=', env.get('id'))
            print('env.name=', env.get('name'))
            print('env.serviceIds=', env.get('serviceIds'))
        if fname == 'render_deploys.json':
            for dep in data[:5]:
                print('deploy', dep.get('id'), dep.get('status'), dep.get('commit', {}).get('id'))
        if fname == 'render_logs.json':
            if isinstance(data, list):
                for item in data[:40]:
                    msg = item.get('message','')
                    if msg and any(term in msg.lower() for term in ['error','failed','refused','conn']):
                        print('log', item.get('timestamp'), item.get('level'), msg.replace('\n',' ')[:300])
                print('total logs', len(data))
    except Exception as e:
        print('failed parse', e)
        if fname == 'render_logs.json':
            text = raw.decode(enc, errors='replace')
            lines = [line.strip() for line in text.splitlines() if line.strip()]
            print('lines', len(lines))
            for i, line in enumerate(lines[:40]):
                try:
                    obj = json.loads(line)
                    msg = obj.get('message','')
                    if msg and any(term in msg.lower() for term in ['error','failed','refused','conn']):
                        print('line', i, obj.get('timestamp'), obj.get('level'), msg.replace('\n',' ')[:300])
                except Exception as e2:
                    print('line', i, 'json fail', e2)
