"""
Genera los efectos de sonido del juego de forma procedural (sonidos originales,
sintetizados con numpy/scipy — no son grabaciones de terceros).

Cada disparo se arma por capas, como un disparo real grabado:
  1) transitorio seco (percusión/gatillo)
  2) "crack" de banda ancha (la propia detonación)
  3) golpe grave (onda de presión)
  4) acción mecánica (corredera/cerrojo/mecanismo) un poco después del disparo
  5) cola de sala (un pequeño eco de reflexiones tempranas, filtradas)

Cada arma tiene 3 variaciones (ligeros cambios de timbre/duración) para que una
ráfaga no suene como el mismo sample repetido. La minigun además tiene un motor
(arranque / bucle / frenado) para acompañar el giro de los cañones.

Uso:  python3 generar_sonidos.py <carpeta_salida>
"""
import sys, wave
import numpy as np
from scipy.signal import butter, sosfilt

SR = 44100
rng = np.random.default_rng(11)  # semilla fija => siempre genera lo mismo


# ---------------------------------------------------------------- utilidades
def t_axis(dur):
    return np.arange(int(SR * dur)) / SR


def noise(dur):
    return rng.uniform(-1, 1, int(SR * dur))


def lp(x, fc, order=2):
    fc = min(fc, SR / 2 - 100)
    return sosfilt(butter(order, fc, "low", fs=SR, output="sos"), x)


def hp(x, fc, order=2):
    return sosfilt(butter(order, fc, "high", fs=SR, output="sos"), x)


def bp(x, lo, hi, order=2):
    hi = min(hi, SR / 2 - 100)
    return sosfilt(butter(order, [lo, hi], "band", fs=SR, output="sos"), x)


def env_exp(n, tau):
    return np.exp(-np.arange(n) / (SR * tau))


def sweep_sine(dur, f0, f1, tau_f=0.03):
    t = t_axis(dur)
    f = f1 + (f0 - f1) * np.exp(-t / tau_f)
    fase = 2 * np.pi * np.cumsum(f) / SR
    return np.sin(fase)


def attack(x, ms=0.5):
    n = max(1, int(SR * ms / 1000))
    x = x.copy()
    x[:n] *= np.linspace(0, 1, n)
    return x


def fade_out(x, ms=6):
    n = int(SR * ms / 1000)
    if n < len(x):
        x = x.copy()
        x[-n:] *= np.linspace(1, 0, n)
    return x


def pad(x, dur):
    out = np.zeros(int(SR * dur))
    out[: min(len(x), len(out))] = x[: len(out)]
    return out


def mix(*parts, dur):
    out = np.zeros(int(SR * dur))
    for p in parts:
        n = min(len(p), len(out))
        out[:n] += p[:n]
    return out


def normalize(x, peak):
    m = np.max(np.abs(x))
    return x / m * peak if m > 0 else x


def softclip(x, drive=1.4):
    return np.tanh(drive * x) / np.tanh(drive)


def sala(x, taps, dur):
    """Eco de sala barato: unas pocas reflexiones tempranas, filtradas y atenuadas."""
    out = pad(x, dur)
    for delay_ms, ganancia, corte in taps:
        d = int(SR * delay_ms / 1000)
        eco = lp(x, corte) * ganancia
        n = min(len(eco), len(out) - d)
        if n > 0:
            out[d : d + n] += eco[:n]
    return out


# ------------------------------------------------------------- capas de arma
def _transitorio(dur_ms, lo, hi, tau):
    d = dur_ms / 1000.0
    n = int(SR * d)
    return bp(noise(d), lo, hi) * env_exp(n, tau)


def _mecanismo(dur, retardo_ms, freqs, tau, amp=0.14):
    """Clic metálico de la corredera/cerrojo/mecanismo, un poco después del disparo."""
    n_total = int(SR * dur)
    capa = np.zeros(n_total)
    ini = int(SR * retardo_ms / 1000)
    largo = min(int(SR * 0.03), n_total - ini)
    if largo <= 0:
        return capa
    t = t_axis(largo / SR)
    tono = sum(np.sin(2 * np.pi * f * t) for f in freqs) / len(freqs)
    metal = (tono * 0.6 + hp(noise(largo / SR), 2500) * 0.5) * env_exp(largo, tau)
    capa[ini : ini + largo] = metal[:largo] * amp
    return capa


def disparo_pistola(variacion=0):
    rng_local = np.random.default_rng(200 + variacion)
    dur = 0.40
    n = int(SR * dur)
    jitter = lambda a, b: rng_local.uniform(a, b)

    click = _transitorio(9, 700, 3400, 0.0024)
    body_raw = noise(dur)
    body = lp(body_raw, 2400 * jitter(0.93, 1.07)) * env_exp(n, 0.032 * jitter(0.9, 1.1))
    body_low = lp(body_raw, 1200) * env_exp(n, 0.075 * jitter(0.9, 1.1))
    thump = sweep_sine(dur, 200 * jitter(0.95, 1.05), 55, 0.022) * env_exp(n, 0.055)
    mecanismo = _mecanismo(dur, jitter(55, 80), [2100, 3400], 0.010, amp=0.13)
    seco = mix(pad(click, dur) * 0.75, body * 0.85, body_low * 0.8, thump * 1.1, mecanismo, dur=dur)
    con_sala = sala(seco, [(14, 0.30, 2000), (34, 0.16, 1400), (66, 0.08, 900)], dur)
    x = fade_out(attack(con_sala))
    return softclip(normalize(x, 0.88), 1.3) * 0.75


def disparo_rifle(variacion=0):
    rng_local = np.random.default_rng(300 + variacion)
    dur = 0.30
    n = int(SR * dur)
    jitter = lambda a, b: rng_local.uniform(a, b)

    click = _transitorio(7, 900, 3800, 0.0016)
    crack = bp(noise(dur), 700 * jitter(0.9, 1.1), 3000) * env_exp(n, 0.017 * jitter(0.9, 1.1))
    body = lp(noise(dur), 1100) * env_exp(n, 0.056)
    thump = sweep_sine(dur, 240 * jitter(0.95, 1.05), 78, 0.017) * env_exp(n, 0.046)
    mecanismo = _mecanismo(dur, jitter(60, 85), [1800, 3100, 4600], 0.012, amp=0.16)
    seco = mix(pad(click, dur) * 0.85, crack * 0.75, body * 0.85, thump * 1.05, mecanismo, dur=dur)
    con_sala = sala(seco, [(11, 0.34, 2400), (27, 0.20, 1600), (52, 0.11, 1000), (95, 0.05, 700)], dur)
    x = fade_out(attack(con_sala, 0.3))
    return softclip(normalize(x, 0.9), 1.35) * 0.72


def disparo_minigun(variacion=0):
    """Disparo individual del M134: más metálico y seco que el rifle (mecanismo
    rotativo alimentado por cinta) y con una cola de sala muy corta."""
    rng_local = np.random.default_rng(400 + variacion)
    dur = 0.15
    n = int(SR * dur)
    jitter = lambda a, b: rng_local.uniform(a, b)

    click = _transitorio(5, 1100, 4600, 0.0011)
    crack = bp(noise(dur), 900 * jitter(0.9, 1.1), 3800) * env_exp(n, 0.011)
    body = lp(noise(dur), 1400) * env_exp(n, 0.022)
    thump = sweep_sine(dur, 260 * jitter(0.95, 1.05), 95, 0.011) * env_exp(n, 0.024)
    metal = _mecanismo(dur, jitter(8, 16), [2600, 4100], 0.008, amp=0.22)
    seco = mix(pad(click, dur), crack * 0.85, body * 0.55, thump * 0.7, metal, dur=dur)
    con_sala = sala(seco, [(8, 0.20, 2600), (18, 0.10, 1800)], dur)
    x = fade_out(attack(con_sala, 0.25), 5)
    return softclip(normalize(x, 0.85), 1.3) * 0.55


# ------------------------------------------------------- motor de la minigun
def _whine(dur, f0, f1, brillo, amp_ruido=0.35):
    """Zumbido de motor/servo: un diente de sierra con armónicos + ruido filtrado."""
    t = t_axis(dur)
    f = np.linspace(f0, f1, len(t))
    fase = 2 * np.pi * np.cumsum(f) / SR
    diente = 2 * (fase / (2 * np.pi) % 1.0) - 1.0
    armonico = 0.5 * np.sin(2 * fase) + 0.25 * np.sin(3 * fase)
    motor = diente * 0.6 + armonico
    motor = lp(motor, brillo)
    grano = bp(noise(dur), 300, brillo * 1.4) * amp_ruido
    return motor * 0.7 + grano


def minigun_motor_arranque():
    dur = 0.55
    x = _whine(dur, 55, 340, 2600)
    env = np.clip(np.linspace(0, 1, len(x)) ** 0.6, 0, 1)
    x *= env
    return softclip(normalize(fade_out(x, 10), 0.5), 1.2)


def minigun_motor_bucle():
    dur = 0.6
    x = _whine(dur, 340, 340, 2600, amp_ruido=0.30)
    # cruce corto en los bordes para que el bucle no chasquee
    n = int(SR * 0.015)
    fade = np.linspace(0, 1, n)
    x[:n] = x[:n] * fade + x[-n:] * (1 - fade)
    return softclip(normalize(x, 0.42), 1.15)


def minigun_motor_freno():
    dur = 0.7
    x = _whine(dur, 340, 40, 2200, amp_ruido=0.30)
    env = np.linspace(1, 0, len(x)) ** 0.7
    x *= env
    return softclip(normalize(fade_out(x, 15), 0.42), 1.15)


# ------------------------------------------------------------ objetivos
def impacto(variacion=0):
    rng_local = np.random.default_rng(500 + variacion)
    dur = 0.11
    n = int(SR * dur)
    t = t_axis(dur)
    f = 1046.5 * rng_local.uniform(0.97, 1.03)
    x = (np.sin(2 * np.pi * f * t) * 0.7 + np.sin(2 * np.pi * f * 1.5 * t) * 0.45
         + np.sin(2 * np.pi * f * 2.0 * t) * 0.15) * env_exp(n, 0.028)
    x = fade_out(attack(x, 0.4), 8)
    return normalize(x, 0.55)


def pop(variacion=0):
    rng_local = np.random.default_rng(600 + variacion)
    dur = 0.22
    n = int(SR * dur)
    burst = bp(noise(dur), 1500, 6500) * env_exp(n, 0.030)
    blip = sweep_sine(dur, 950 * rng_local.uniform(0.95, 1.05), 260, 0.040) * env_exp(n, 0.055)
    sparkle = bp(noise(dur), 4000, 8000) * env_exp(n, 0.012) * 0.35
    x = mix(burst * 0.8, blip * 0.9, sparkle, dur=dur)
    x = fade_out(attack(x, 0.4), 10)
    return softclip(normalize(x, 0.85)) * 0.65


def golpe_enemigo():
    """Impacto que NO mata: un tic corto y seco (distinto de 'pop', que es la muerte)."""
    dur = 0.07
    n = int(SR * dur)
    t = t_axis(dur)
    x = (np.sin(2 * np.pi * 700 * t) * 0.6 + bp(noise(dur), 900, 3500) * 0.5) * env_exp(n, 0.014)
    x = fade_out(attack(x, 0.3), 6)
    return normalize(x, 0.42)


# ------------------------------------------------------------------- UI
def ui_click(variacion=0):
    rng_local = np.random.default_rng(700 + variacion)
    dur = 0.04
    n = int(SR * dur)
    t = t_axis(dur)
    tick = bp(noise(dur), 500, 3500) * env_exp(n, 0.0030)
    res = np.sin(2 * np.pi * 1500 * rng_local.uniform(0.97, 1.03) * t) * env_exp(n, 0.008)
    body = np.sin(2 * np.pi * 420 * t) * env_exp(n, 0.010)
    x = mix(tick * 0.9, res * 0.5, body * 0.9, dur=dur)
    x = fade_out(attack(x, 0.2), 4)
    return normalize(x, 0.5)


def ui_hover():
    dur = 0.03
    n = int(SR * dur)
    t = t_axis(dur)
    x = (np.sin(2 * np.pi * 1900 * t) * 0.6 + bp(noise(dur), 1000, 4000) * 0.3) * env_exp(n, 0.006)
    x = fade_out(attack(x, 0.2), 4)
    return normalize(x, 0.26)


# -------------------------------------------------------------- catálogo
# nombre_base -> (función, nº de variaciones). 1 variación => archivo único "nombre.wav".
SONIDOS = {
    "disparo_pistola": (disparo_pistola, 3),
    "disparo_rifle": (disparo_rifle, 3),
    "disparo_minigun": (disparo_minigun, 3),
    "impacto": (impacto, 2),
    "pop": (pop, 2),
    "golpe_enemigo": (lambda v=0: golpe_enemigo(), 1),
    "ui_click": (ui_click, 2),
    "ui_hover": (lambda v=0: ui_hover(), 1),
    "minigun_motor_arranque": (lambda v=0: minigun_motor_arranque(), 1),
    "minigun_motor_bucle": (lambda v=0: minigun_motor_bucle(), 1),
    "minigun_motor_freno": (lambda v=0: minigun_motor_freno(), 1),
}


def guardar(path, x):
    x = np.clip(x, -1, 1)
    data = (x * 32767).astype("<i2").tobytes()
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data)


if __name__ == "__main__":
    out = sys.argv[1] if len(sys.argv) > 1 else "."
    for nombre, (fn, n_var) in SONIDOS.items():
        if n_var == 1:
            x = fn()
            guardar(f"{out}/{nombre}.wav", x)
            print(f"{nombre}.wav  {len(x)/SR*1000:.0f} ms  pico={np.max(np.abs(x)):.2f}")
        else:
            for v in range(1, n_var + 1):
                x = fn(v)
                guardar(f"{out}/{nombre}_{v}.wav", x)
                print(f"{nombre}_{v}.wav  {len(x)/SR*1000:.0f} ms  pico={np.max(np.abs(x)):.2f}")
