/**
 * SilverTech Agent Adam — Voice WebSocket Handler
 * Real-time voice streaming: STT → LLM → TTS pipeline
 * June 2026 — low-latency bidirectional audio streaming
 */

async function voiceSocket(fastify, options) {
  fastify.get('/stream', { websocket: true }, (socket, request) => {
    const callId = request.query.callId || `ws_${Date.now()}`;
    let callActive = false;

    fastify.log.info(`Voice WebSocket connected: ${callId}`);

    socket.on('message', async (rawMessage) => {
      try {
        const message = JSON.parse(rawMessage.toString());

        switch (message.type) {
          case 'call_start':
            callActive = true;
            socket.send(JSON.stringify({
              type: 'status',
              callId,
              status: 'connected',
              timestamp: Date.now(),
            }));

            // Send Adam greeting
            socket.send(JSON.stringify({
              type: 'transcript',
              speaker: 'adam',
              text: 'Dzień dobry! Tu Adam. Jak się dziś czujesz?',
              timestamp: Date.now(),
            }));

            // In production: initialize Deepgram STT stream
            // In production: initialize Gemini LLM session
            break;

          case 'audio_chunk':
            if (!callActive) break;

            // In production: forward audio to Deepgram STT
            // const transcript = await deepgram.transcribe(message.payload);

            // Simulate processing
            socket.send(JSON.stringify({
              type: 'processing',
              status: 'received_chunk',
              size: message.payload?.length || 0,
            }));
            break;

          case 'stt_result':
            // In production: this comes from Deepgram callback
            const seniorText = message.text;

            socket.send(JSON.stringify({
              type: 'transcript',
              speaker: 'senior',
              text: seniorText,
              confidence: 0.95,
              timestamp: Date.now(),
            }));

            // Forward to LLM for response
            // const llmResponse = await gemini.generate(seniorText, context);
            // Send to TTS
            // const audioChunk = await openai.tts(llmResponse);

            socket.send(JSON.stringify({
              type: 'transcript',
              speaker: 'adam',
              text: 'Rozumiem. Czy jest coś jeszcze, w czym mogę pomóc?',
              timestamp: Date.now(),
            }));
            break;

          case 'call_end':
            callActive = false;
            socket.send(JSON.stringify({
              type: 'status',
              status: 'ended',
              callId,
              duration: message.duration || 0,
            }));
            break;

          case 'ping':
            socket.send(JSON.stringify({ type: 'pong', timestamp: Date.now() }));
            break;

          default:
            socket.send(JSON.stringify({
              type: 'error',
              message: `Unknown message type: ${message.type}`,
            }));
        }
      } catch (err) {
        fastify.log.error(`WebSocket error: ${err.message}`);
        socket.send(JSON.stringify({
          type: 'error',
          message: 'Internal processing error',
        }));
      }
    });

    socket.on('close', () => {
      callActive = false;
      fastify.log.info(`Voice WebSocket disconnected: ${callId}`);
    });

    // Heartbeat to keep connection alive
    const heartbeat = setInterval(() => {
      if (socket.readyState === 1) { // OPEN
        socket.send(JSON.stringify({ type: 'heartbeat', timestamp: Date.now() }));
      } else {
        clearInterval(heartbeat);
      }
    }, 30000);

    socket.on('close', () => clearInterval(heartbeat));
  });
}

module.exports = voiceSocket;
