// assets/js/app.js

const FileHook = {
    mounted() {
        console.log('FileHook mounted');
        // Sélectionner le formulaire et l'input file
        const form = this.el;
        const fileInput = form.querySelector('input[type="file"]');

        // Écouter l'événement de soumission du formulaire
        form.addEventListener('submit', (event) => {
            event.preventDefault(); // Empêcher la soumission par défaut
            console.log('file submit');
            // Vérifier si un fichier est sélectionné
            if (fileInput.files.length > 0) {
                const file = fileInput.files[0];
                console.log('file', file);
                // Lire le fichier en tant que ArrayBuffer
                const reader = new FileReader();
                reader.onload = (e) => {
                    const fileData = new Uint8Array(e.target.result);

                    // Pousser l'événement vers LiveView avec les données du fichier
                    this.pushEvent('upload_file', { filename: file.name, data: Array.from(fileData) });
                };
                reader.readAsArrayBuffer(file);
            } else {
                console.log('Aucun fichier sélectionné');
            }
        });
    },
};

// Exporter les hooks
export default FileHook;
