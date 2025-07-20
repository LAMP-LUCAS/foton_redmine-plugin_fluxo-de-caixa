import os
import subprocess

CONFIG_FILE = os.path.join(os.path.dirname(__file__), '.config')

def load_config():
    config = {
        'CONTAINER_NAME': 'foton_redmine',
        'PLUGINS_PATH': '/caminho/para/redmine/plugins',
        'PLUGIN_DIR': 'redmine_cash_flow_pro',
    }
    if os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE, 'r', encoding='utf-8') as f:
            for line in f:
                if '=' in line and not line.strip().startswith('#'):
                    k, v = line.strip().split('=', 1)
                    config[k.strip()] = v.strip()
    return config

def run(cmd):
    print(f'Executando: {cmd}')
    subprocess.run(cmd, shell=True, check=True)

def update():
    cfg = load_config()
    plugin_path = os.path.join(cfg['PLUGINS_PATH'], cfg['PLUGIN_DIR'])
    os.chdir(plugin_path)
    try:
        print('Atualizando repositório do plugin...')
        run('git pull origin main')
    except:
        print('\n\nErro ao realizar pull do github...\n\n')
    print('Executando migrações do plugin...')
    run(f"docker compose exec {cfg['CONTAINER_NAME']} bundle exec rake redmine:plugins:migrate RAILS_ENV=production")
    print('Publicando assets do plugin...')
    run(f"docker compose exec {cfg['CONTAINER_NAME']} bundle exec rake redmine:plugins:assets RAILS_ENV=production")
    print('Reiniciando o Redmine...')
    run(f"docker compose restart {cfg['CONTAINER_NAME']}")
    print('Atualização concluída!')

if __name__ == '__main__':
    update()
