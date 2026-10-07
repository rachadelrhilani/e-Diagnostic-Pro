<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../templates/header.jsp" />

<div class="max-w-4xl mx-auto">
    <div class="mb-6 p-4 rounded-xl bg-amber-500/10 border border-amber-500/30 text-amber-200 text-sm">
        ⚠️ Aucun dossier trouvé pour le NSS : <strong class="font-bold">${nssSaisi}</strong>. Veuillez créer la fiche du patient.
    </div>

    <form action="${pageContext.request.contextPath}/infirmier/creer-patient" method="post" class="space-y-8">
        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}" />
        <input type="hidden" name="nss" value="${nssSaisi}" />

        <!-- 1. Informations Personnelles -->
        <div class="p-6 rounded-2xl bg-slate-800/40 border border-slate-700/50 backdrop-blur-md">
            <h3 class="text-base font-bold text-white mb-4 flex items-center gap-2">👤 Informations Personnelles</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Nom</label>
                    <input type="text" name="nom" required class="w-full px-4 py-2.5 rounded-xl bg-slate-900/60 border border-slate-700 text-white text-sm focus:outline-none" />
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Prénom</label>
                    <input type="text" name="prenom" required class="w-full px-4 py-2.5 rounded-xl bg-slate-900/60 border border-slate-700 text-white text-sm focus:outline-none" />
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Date de Naissance</label>
                    <input type="date" name="dateNaissance" required class="w-full px-4 py-2.5 rounded-xl bg-slate-900/60 border border-slate-700 text-white text-sm focus:outline-none" />
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Téléphone</label>
                    <input type="text" name="telephone" class="w-full px-4 py-2.5 rounded-xl bg-slate-900/60 border border-slate-700 text-white text-sm focus:outline-none" />
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Mutuelle</label>
                    <input type="text" name="mutuelle" placeholder="ex: CNSS, CNOPS" class="w-full px-4 py-2.5 rounded-xl bg-slate-900/60 border border-slate-700 text-white text-sm focus:outline-none" />
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Adresse</label>
                    <input type="text" name="adresse" class="w-full px-4 py-2.5 rounded-xl bg-slate-900/60 border border-slate-700 text-white text-sm focus:outline-none" />
                </div>
            </div>
        </div>

        <!-- 2. Signes Vitaux d'admission -->
        <div class="p-6 rounded-2xl bg-slate-800/40 border border-slate-700/50 backdrop-blur-md">
            <h3 class="text-base font-bold text-white mb-4 flex items-center gap-2">🩺 Signes Vitaux d'Admission</h3>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Tension (mmHg)</label>
                    <input type="text" name="tension" placeholder="12/8" required class="w-full px-4 py-2.5 rounded-xl bg-slate-900/60 border border-slate-700 text-white text-sm focus:outline-none" />
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Fréq. Cardiaque (BPM)</label>
                    <input type="number" name="frequenceCardiaque" placeholder="75" required class="w-full px-4 py-2.5 rounded-xl bg-slate-900/60 border border-slate-700 text-white text-sm focus:outline-none" />
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Température (°C)</label>
                    <input type="number" step="0.1" name="temperature" placeholder="37.0" required class="w-full px-4 py-2.5 rounded-xl bg-slate-900/60 border border-slate-700 text-white text-sm focus:outline-none" />
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Fréq. Respiratoire</label>
                    <input type="number" name="frequenceRespiratoire" class="w-full px-4 py-2.5 rounded-xl bg-slate-900/60 border border-slate-700 text-white text-sm focus:outline-none" />
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Poids (kg)</label>
                    <input type="number" step="0.1" name="poids" class="w-full px-4 py-2.5 rounded-xl bg-slate-900/60 border border-slate-700 text-white text-sm focus:outline-none" />
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Taille (cm)</label>
                    <input type="number" step="0.1" name="taille" class="w-full px-4 py-2.5 rounded-xl bg-slate-900/60 border border-slate-700 text-white text-sm focus:outline-none" />
                </div>
            </div>
        </div>

        <button type="submit" class="w-full py-3 px-4 rounded-xl bg-indigo-600 hover:bg-indigo-500 text-white font-semibold shadow-lg shadow-indigo-600/30 border border-indigo-400/30 transition text-sm">
            Enregistrer le patient et les constantes
        </button>
    </form>
</div>