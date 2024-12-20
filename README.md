# LekoTools

1. [LekoTools](#lekotools)
	1. [1. Wprowadzenie](#1-wprowadzenie)
	2. [2. Instalacja](#2-instalacja)
		1. [2.1 Wymagania](#21-wymagania)
		2. [2.2 Instalacja](#22-instalacja)
	3. [3. Użycie](#3-użycie)
	4. [4. Aktualizacja](#4-aktualizacja)

## 1. Wprowadzenie

LekoTools to narzędzie do konfiguracji urządzeń (przede wszystkim ładowarek do pojazdów elektrycznych).

## 2. Instalacja

### 2.1 Wymagania

Jedynym wymogiem jest **powłoka <ins>bash</ins>** i menadżer pakietów. Pozostałe zależności program pobierze sam.

### 2.2 Instalacja

W celu instalacji programu użyj poniższej komendy w terminalu

```bash
mkdir -p ~/LekoTools && cd ~/LekoTools && git config --global credential.helper store && git clone -b main https://github.com/Guliveer/LekoTools.git . && git init
```

## 3. Użycie

Aby uruchomić program, w terminalu skorzystaj z polecenia

```bash
bash ~/LekoTools/LekoTools.sh
```

lub dodaj alias do pliku `.bashrc` i uruchamiaj skrypt za pomocą wybranego aliasu (np. _lekotools_)

```bash
echo "alias lekotools='bash ~/LekoTools/LekoTools.sh'" >> ~/.bashrc && source ~/.bashrc
```

## 4. Aktualizacja

Program automatycznie sprawdza dostępność aktualizacji, ale istnieje także możliwość ręcznego sprawdzenia aktualizacji w zakładce `Ustawienia > Sprawdź aktualizacje`
