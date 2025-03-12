import numpy as np
from pydub import AudioSegment
from pydub.playback import play

# Parámetros del ritmo binaural
frecuencia_izquierda = 369  # Hz
frecuencia_derecha = 369  # Hz
duracion = 15000  # ms
sample_rate = 44100  # Hz (frecuencia de muestreo)

# Genera las ondas sinusoidales
t = np.linspace(0, duracion / 1000, int(sample_rate * duracion / 1000), False)
onda_izquierda = np.sin(frecuencia_izquierda * 2 * np.pi * t)
onda_derecha = np.sin(frecuencia_derecha * 2 * np.pi * t)

# Combina las ondas en un array estéreo
stereo_data = np.array([onda_izquierda, onda_derecha]).T

# Convierte a formato de pydub
audio = AudioSegment(
    stereo_data.astype("float32").tobytes(),
    frame_rate=sample_rate,
    sample_width=4,
    channels=2,
)

# Guarda el audio
audio.export("audios/binaural.wav", format="wav", bitrate="192k")