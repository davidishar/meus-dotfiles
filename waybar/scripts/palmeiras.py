#!/usr/bin/env python3
import sys
import time
import json
import os
import requests
from datetime import datetime, timezone

CACHE_FILE = os.path.expanduser("~/.cache/waybar_palmeiras.json")

def fetch_api_data():
    """Busca os dados oficiais, garantindo que pegue jogos AO VIVO."""
    headers = {
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64)',
        'Accept': 'application/json',
        'Referer': 'https://www.sofascore.com/'
    }
    
    try:
        event = None
        
        # 1. Primeiro procuramos por um jogo AO VIVO na lista de jogos iniciados/passados
        url_last = "https://api.sofascore.com/api/v1/team/1963/events/last/0"
        res_last = requests.get(url_last, headers=headers, timeout=10)
        if res_last.status_code == 200:
            data_last = res_last.json()
            # Varre os últimos jogos para ver se algum está rolando agora ('inprogress')
            for e in data_last.get('events', []):
                if e['status']['type'] == 'inprogress':
                    event = e
                    break
        
        # 2. Se nenhum jogo está rolando ao vivo, pegamos o próximo da agenda
        if not event:
            url_next = "https://api.sofascore.com/api/v1/team/1963/events/next/0"
            res_next = requests.get(url_next, headers=headers, timeout=10)
            res_next.raise_for_status()
            data_next = res_next.json()
            event = data_next['events'][0]
            
        event_id = event['id']
        status_code = event['status']['type']
        
        if status_code == 'notstarted': status = 'WAITING'
        elif status_code == 'finished': status = 'FINISHED'
        else: status = 'LIVE' # O 'inprogress' cai aqui
        
        home_team = event['homeTeam'].get('nameCode', event['homeTeam']['shortName'][:3]).upper()
        away_team = event['awayTeam'].get('nameCode', event['awayTeam']['shortName'][:3]).upper()
        
        home_full = event['homeTeam']['name']
        away_full = event['awayTeam']['name']
        
        home_score = event.get('homeScore', {}).get('current', 0)
        away_score = event.get('awayScore', {}).get('current', 0)
        
        game_date = datetime.fromtimestamp(event['startTimestamp'], tz=timezone.utc).astimezone()
        campeonato = event['tournament']['name']

        # 3. Busca o detalhe do estádio
        estadio = "A definir"
        try:
            url_event = f"https://api.sofascore.com/api/v1/event/{event_id}"
            res_event = requests.get(url_event, headers=headers, timeout=5)
            if res_event.status_code == 200:
                venue = res_event.json().get('event', {}).get('venue', {})
                estadio = venue.get('stadium', {}).get('name', 'A definir')
        except:
            pass 

        # 4. Lógica do relógio em tempo real
        match_time = ""
        if status == 'LIVE':
            desc_en = event['status'].get('description', '')
            traducao = {
                '1st half': '1ºT',
                '2nd half': '2ºT',
                'Halftime': 'Intervalo',
                'Extra time': 'Prorrogação',
                'Penalties': 'Pênaltis'
            }
            periodo = traducao.get(desc_en, desc_en)
            minuto = event.get('time', {}).get('current')
            
            if periodo == 'Intervalo':
                match_time = "Intervalo"
            elif minuto and periodo:
                match_time = f"{minuto}' ({periodo})"
            elif minuto:
                match_time = f"{minuto}'"
            else:
                match_time = "Em andamento"

        return {
            "status": status,
            "home": home_team,
            "away": away_team,
            "home_full": home_full,
            "away_full": away_full,
            "score_h": home_score,
            "score_a": away_score,
            "game_time": game_date,
            "campeonato": campeonato,
            "estadio": estadio,
            "match_time": match_time
        }
        
    except Exception as e:
        raise Exception(f"Erro na extração ({e}).")

def load_offline_cache():
    if os.path.exists(CACHE_FILE):
        try:
            with open(CACHE_FILE, 'r') as f:
                return json.load(f)
        except:
            pass
    return None

def save_cache(text, tooltip):
    with open(CACHE_FILE, 'w') as f:
        json.dump({"text": text, "tooltip": tooltip}, f)

def main():
    while True:
        try:
            game = fetch_api_data()
            now = datetime.now().astimezone()

            if game["status"] == "WAITING":
                text = f"🐷"
                linhas_tooltip = [
                    f"🟢 {game['home_full']} x {game['away_full']}",
                    f"⏰ Início: {game['game_time'].strftime('%H:%M')} ({game['game_time'].strftime('%d/%m')})",
                    f"🏟️ {game['estadio']}",
                    f"🏆 {game['campeonato']}"
                ]
                sleep_time = min((game['game_time'] - now).total_seconds(), 3600)
                if sleep_time < 0: sleep_time = 60
                
            elif game["status"] == "LIVE":
                text = f"{game['home']} {game['score_h']}-{game['score_a']} {game['away']}"
                linhas_tooltip = [
                    f"🔥 {game['home_full']} {game['score_h']} x {game['score_a']} {game['away_full']}",
                    f"⏱️ Tempo: {game['match_time']}",
                    f"🏟️ {game['estadio']}",
                    f"🏆 {game['campeonato']}"
                ]
                sleep_time = 60
                
            elif game["status"] == "FINISHED":
                text = f"🏁 {game['home']} {game['score_h']}-{game['score_a']} {game['away']}"
                linhas_tooltip = [
                    "Fim de Jogo",
                    f"{game['home_full']} {game['score_h']} x {game['score_a']} {game['away_full']}",
                    f"🏟️ {game['estadio']}",
                    f"🏆 {game['campeonato']}"
                ]
                sleep_time = 12 * 3600

            tooltip = "\n".join([linha for linha in linhas_tooltip if linha.strip()])
            text = text[:50] 
            
            save_cache(text, tooltip)

            print(json.dumps({"text": text, "tooltip": tooltip}))
            sys.stdout.flush()
            time.sleep(sleep_time)

        except Exception as e:
            backup = load_offline_cache()
            if backup:
                backup_tooltip = backup.get("tooltip", "") + "\n\n(Modo Offline)"
                print(json.dumps({"text": backup.get("text", ""), "tooltip": backup_tooltip}))
            else:
                print(json.dumps({"text": "🦇 Offline", "tooltip": f"Sem conexão.\nDetalhe: {str(e)}"}))
            
            sys.stdout.flush()
            time.sleep(60)

if __name__ == "__main__":
    main()