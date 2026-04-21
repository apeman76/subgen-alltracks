FROM nvidia/cuda:13.2.0-base-ubuntu24.04

COPY requirements.txt entrypoint.sh /

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-venv \
    ffmpeg curl gosu tzdata \
    && rm -rf /var/lib/apt/lists/*

# Optional but recommended: virtualenv (avoids PEP 668 issues entirely)
RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"

# Install PyTorch (still cu124)
RUN pip install --no-cache-dir \
    torch torchaudio --index-url https://download.pytorch.org/whl/cu124

RUN pip install --no-cache-dir -r requirements.txt

WORKDIR /subgen

COPY launcher.py subgen.py language_code.py /subgen/

RUN mkdir -p /cache && chmod 777 /cache

ENV XDG_CACHE_HOME=/cache \
    HF_HOME=/cache/huggingface \
    MPLCONFIGDIR=/cache/matplotlib \
    PYTHONUNBUFFERED=1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["python3", "launcher.py"]