#!/usr/bin/env python3
import json
import requests
import os
import time

# --- CONFIGURAÇÕES ---
LAT = "-16.7167"
LON = "-43.8667"
CACHE_FILE = os.path.expanduser("~/.cache/waybar-weather.json")
CACHE_TIMEOUT = 900  # 15 minutos em segundos

WMO_ICONS = {
    0: "󰖙",  # Céu limpo (Sol)
    1: "󰖕",  # Principalmente limpo (Sol com pequena nuvem)
    2: "󰖐",  # Parcialmente nublado (Nuvem)
    3: "󰖐",  # Nublado (Nuvem)
    45: "󰖑", # Neblina
    48: "󰖑", # Neblina
    51: "󰖗", # Chuvisco leve (Nuvem com chuva leve)
    53: "󰖗", # Chuvisco moderado
    55: "󰖗", # Chuvisco denso
    61: "󰖖", # Chuva leve (Nuvem com chuva forte)
    63: "󰖖", # Chuva moderada
    65: "󰖖", # Chuva forte
    80: "󰖖", # Pancadas de chuva leves
    81: "󰖒", # Pancadas de chuva fortes (Nuvem com raio e chuva)
    82: "󰖒", # Pancadas de chuva violentas
    95: "󰖓", # Tempestade (Nuvem com raio)
    96: "󰖒", # Tempestade com granizo leve
    99: "󰖒", # Tempestade com granizo forte
}

def get_icon(code, is_day):
    if not is_day and code in [0, 1]:
        return "󰖔"  # Lua limpa para noites sem nuvens
    return WMO_ICONS.get(code, "")  # Termômetro como fallback de erro

def fetch_weather(delays=[5, 15, 40]):
    """
    Tenta baixar o clima imediatamente. Se falhar, tenta de novo 
    esperando os tempos da lista de forma gradual. O total soma 60s.
    """
    url = f"https://api.open-meteo.com/v1/forecast?latitude={LAT}&longitude={LON}&current=temperature_2m,weather_code,is_day,relative_humidity_2m&daily=temperature_2m_max,temperature_2m_min&timezone=America%2FSao_Paulo"
    
    # 1ª Tentativa (imediata)
    try:
        response = requests.get(url, timeout=5)
        response.raise_for_status() 
        return response.json()
    except requests.RequestException:
        pass # Se falhar na hora, segue para o loop com atrasos
            
    # Tentativas graduais
    for delay in delays:
        time.sleep(delay)
        try:
            response = requests.get(url, timeout=5)
            response.raise_for_status() 
            return response.json()
        except requests.RequestException:
            continue # Falhou de novo, vai para o próximo tempo de espera
            
    return None

def load_cache():
    try:
        with open(CACHE_FILE, "r") as f:
            return json.load(f)
    except:
        return None

def main():
    data = None
    is_offline_fallback = False
    
    if os.path.exists(CACHE_FILE):
        file_age = time.time() - os.path.getmtime(CACHE_FILE)
        if file_age < CACHE_TIMEOUT:
            data = load_cache()

    if not data:
        # Agora ele usa a lista gradual: tenta agora, depois de 5s, 15s e 40s.
        new_data = fetch_weather() 
        if new_data:
            data = new_data
            with open(CACHE_FILE, "w") as f:
                json.dump(data, f)
        elif os.path.exists(CACHE_FILE):
            data = load_cache()
            is_offline_fallback = True
    
    if data:
        current = data["current"]
        daily = data["daily"]
        
        temp = round(current["temperature_2m"])
        code = current["weather_code"]
        is_day = current["is_day"]
        humidity = current["relative_humidity_2m"]
        
        max_temp = round(daily["temperature_2m_max"][0])
        min_temp = round(daily["temperature_2m_min"][0])

        icon = get_icon(code, is_day)
        
        offline_marker = "*" if is_offline_fallback else ""
        text = f"{icon} {temp}°C{offline_marker}"
        
        tooltip = (f"Montes Claros\n"
                   f"Umidade: {humidity}%\n"
                   f"Máxima: {max_temp}°C\n"
                   f"Mínima: {min_temp}°C")
        
        if is_offline_fallback:
            tooltip += "\n\n(Offline)"
            
        print(json.dumps({"text": text, "tooltip": tooltip, "class": "weather"}))
    else:
        print(json.dumps({"text": " Off", "tooltip": "Sem conexão e sem cache", "class": "offline"}))

if __name__ == "__main__":
    main()