<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../templates/header.jsp" />

<div class="max-w-3xl mx-auto">
    <!-- Fiche Patient Trouvé -->
    <div class="mb-6 p-6 rounded-2xl bg-indigo-500/10 border border-indigo-500/30 flex items-center justify-between">
        <div>
            <span class="px-2.5 py-1 text-[10px] font-bold uppercase rounded-full bg-emerald-500/20 text-emerald-300 border border-emerald-500/30">Patient Identifié</span>
            <h2 class="text-xl font-bold text-white mt-2">${patient.prenom} ${patient.nom}</h2>
            <p class="text-xs text-slate-400">NSS: ${patient.numeroSecuriteSociale} | Mutuelle: ${patient.mutuelle != null ? patient.mutuelle : 'N/A'}</p>
        </div>
        <div class="text-right text-xs text-slate-400">
            <p>Tel: ${patient.telephone}</p>
            <p>Né(e) le: ${patient.dateNaissance}</p>
        </div>
    </div>

    <!-- Formulaire Prise de Constantes -->
    <div class="p-8 rounded-2xl bg-slate-800/40 border border-slate-700/50 backdrop-blur-md shadow-xl">
        <h3 class="text-lg font-bold text-white mb-6 flex items-center gap-2">
            <span>🩺</span> Prise des Signes Vitaux du Jour
        </h3>

        <form action="${pageContext.request.contextPath}/infirmier/ajouter-signes" method="post" class="space-y-6">
            <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}" />
            <input type="hidden" name="patientId" value="${patient.id}" />

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Tension Artérielle (mmHg)</label>
                    <input type="text" name="tension" placeholder="ex: 12/8" required class="w-full px-4 py-2.5 rounded-xl bg-slate-900/60 border border-slate-700 text-white text-sm focus:ring-2 focus:ring-indigo-500/50 focus:outline-none" />
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Fréquence Cardiaque (BPM)</label>
                    <input type="number" name="frequenceCardiaque" placeholder="ex: 75" required class="w-full px-4 py-2.5 rounded-xl bg-slate-900/60 border border-slate-700 text-white text-sm focus:ring-2 focus:ring-indigo-500/50 focus:outline-none" />
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Température (°C)</label>
                    <input type="number" step="0.1" name="temperature" placeholder="ex: 37.2" required class="w-full px-4 py-2.5 rounded-xl bg-slate-900/60 border border-slate-700 text-white text-sm focus:ring-2 focus:ring-indigo-500/50 focus:outline-none" />
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Fréquence Respiratoire (/min)</label>
                    <input type="number" name="frequenceRespiratoire" placeholder="ex: 16" class="w-full px-4 py-2.5 rounded-xl bg-slate-900/60 border border-slate-700 text-white text-sm focus:ring-2 focus:ring-indigo-500/50 focus:outline-none" />
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Poids (kg)</label>
                    <input type="number" step="0.1" name="poids" placeholder="ex: 70.5" class="w-full px-4 py-2.5 rounded-xl bg-slate-900/60 border border-slate-700 text-white text-sm focus:ring-2 focus:ring-indigo-500/50 focus:outline-none" />
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Taille (cm)</label>
                    <input type="number" step="0.1" name="taille" placeholder="ex: 175" class="w-full px-4 py-2.5 rounded-xl bg-slate-900/60 border border-slate-700 text-white text-sm focus:ring-2 focus:ring-indigo-500/50 focus:outline-none" />
                </div>
            </div>

            <button type="submit" class="w-full py-3 px-4 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white font-semibold shadow-lg shadow-emerald-600/30 border border-emerald-400/30 transition text-sm">
                Valider et envoyer en salle d'attente
            </button>
        </form>
    </div>
</div>