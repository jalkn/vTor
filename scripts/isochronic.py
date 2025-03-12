from pydub import AudioSegment
from pydub.generators import Sine
import matplotlib.pyplot as plt
import numpy as np
from pydub import AudioSegment

# Parámetros del tono isocrónico
frecuencia = 369  # Hz (frecuencia del tono)
duracion_tono = 50  # ms (duración del tono)
duracion_silencio = 50 # ms (duración del silencio)
duracion_total = 15000  # ms (duración total del audio)

# Crea el tono
tono = Sine(frecuencia).to_audio_segment(duration=duracion_tono)

# Crea el silencio
silencio = AudioSegment.silent(duration=duracion_silencio)

# Combina el tono y el silencio para crear un ciclo
ciclo = tono + silencio

# Repite el ciclo para alcanzar la duración total
audio = ciclo * int(duracion_total / (duracion_tono + duracion_silencio))

# Guarda el audio
audio.export("audios/isochronico.wav", format="wav")

#images
audio = AudioSegment.from_file("audios/isochronico.wav", format="wav")
samples = audio.get_array_of_samples()
time = np.linspace(0, len(samples) / audio.frame_rate, num=len(samples))

plt.figure(figsize=(10, 4))
plt.plot(time, samples)
plt.xlabel("Time (s)")
plt.ylabel("Amplitude")
plt.title("Waveform of Isochronic Tone")
plt.savefig("images/waveform.png")
plt.show()