from pydub import AudioSegment
from pydub.generators import Sine

# Parámetros del tono isocrónico
frecuencia = 369  # Hz (frecuencia del tono)
duracion_tono = 50  # ms (duración del tono)
duracion_silencio = 50 # ms (duración del silencio)
duracion_total = 5000  # ms (duración total del audio)

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