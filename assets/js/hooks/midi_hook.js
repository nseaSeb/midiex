// assets/js/app.js
let midiAccess = null;
const MidiHook = {
    mounted() {
        console.log('midi hook mounted');
        this.initMIDI();
        this.handleSysExForm();
    },
    // Hook JavaScript modifié

    // Gestion directe du formulaire sans passer par phx-submit
    handleSysExForm() {
        const form = this.el.querySelector('.form_sysex');
        if (form) {
            form.addEventListener('submit', (e) => {
                e.preventDefault();

                const outputSelect = form.querySelector('[name="select_output"]');
                const dataInput = form.querySelector('[name="data"]');
                console.log('data output');
                console.log(dataInput);
                if (outputSelect && dataInput) {
                    const outputId = outputSelect.value;
                    const dataStr = dataInput.value;
                    if (outputId && dataStr) {
                        console.log('Envoi manuel de SysEx:', outputId, dataStr);
                        // Conversion des données
                        const sysexData = dataStr
                            .split(',')
                            .map((s) => s.trim())
                            .filter((s) => s !== '')
                            .map((s) => parseInt(s, 10));

                        this.sendSysEx(outputId, sysexData);
                    } else {
                        console.error('Données ou sortie manquantes');
                    }
                }
            });
        }
    },

    // Initialiser l'accès MIDI
    async initMIDI() {
        try {
            midiAccess = await navigator.requestMIDIAccess({ sysex: true });
            this.pushEvent('midi-access-granted', { sysexEnabled: midiAccess.sysexEnabled });
            this.setupMIDIListeners();
        } catch (error) {
            console.error("Erreur lors de l'accès MIDI:", error);
            this.pushEvent('midi-access-denied', { error: error.message });
        }
    },

    // Configurer les écouteurs pour les entrées/sorties MIDI
    setupMIDIListeners() {
        // Récupérer les interfaces
        const inputs = Array.from(midiAccess.inputs.values());
        const outputs = Array.from(midiAccess.outputs.values());

        // Envoyer les interfaces disponibles au serveur
        this.pushEvent('midi-interfaces', {
            inputs: inputs.map((input) => ({ id: input.id, name: input.name })),
            outputs: outputs.map((output) => ({ id: output.id, name: output.name })),
        });

        // Écouter les messages MIDI entrants
        inputs.forEach((input) => {
            input.onmidimessage = (message) => {
                this.pushEvent('midi-message-received', { data: Array.from(message.data) });
            };
        });
    },

    // AJOUT DE CE HANDLER POUR RÉPONDRE AUX ÉVÉNEMENTS DU SERVEUR
    handleEvent(event, payload) {
        console.log('Event reçu:', event, payload);
        if (event === 'send-sysex') {
            this.sendSysEx(payload.outputId, payload.data);
        }
    },

    // Envoyer un message SysEx
    sendSysEx(outputId, sysexData) {
        console.log('sendSysEx appelé');
        console.log('output ID:', outputId);
        console.log('données SysEx:', sysexData);

        const output = midiAccess.outputs.get(outputId);
        if (output) {
            // Convertir en Uint8Array pour l'API Web MIDI
            const dataArray = new Uint8Array(sysexData);
            output.send(dataArray);
            this.pushEvent('midi-message-sent', { outputId, data: Array.from(dataArray) });
        } else {
            console.error(`Interface de sortie MIDI non trouvée: ${outputId}`);
            this.pushEvent('midi-error', { message: `Interface de sortie MIDI non trouvée: ${outputId}` });
        }
    },
};

// Ajouter le hook à LiveView
export default MidiHook;
