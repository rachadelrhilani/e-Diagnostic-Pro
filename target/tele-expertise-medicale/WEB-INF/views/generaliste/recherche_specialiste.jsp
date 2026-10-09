<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../templates/header.jsp" />

<div class="max-w-6xl mx-auto space-y-6">
    <!-- En-tête -->
    <div class="flex flex-col md:flex-row md:items-center justify-between border-b border-slate-800 pb-4 gap-4">
        <div>
            <div class="flex items-center gap-2 mb-1">
                <span class="px-2.5 py-0.5 rounded-full bg-indigo-500/20 text-indigo-300 text-xs font-bold border border-indigo-500/30">
                    US3 : Télé-Expertise
                </span>
                <h2 class="text-2xl font-bold text-white tracking-wide">Recherche de Médecins Spécialistes</h2>
            </div>
            <p class="text-sm text-slate-400">
                Filtrer par spécialité et tarif maximal via Java Stream API, puis sélectionner un créneau horaire.
            </p>
        </div>

        <c:if test="${fromConsultation && not empty consultationId}">
            <a href="${pageContext.request.contextPath}/generaliste/detail-consultation?id=${consultationId}" 
               class="px-4 py-2 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 text-xs font-semibold border border-slate-700 transition flex items-center gap-2">
                ⬅ Retour au dossier
            </a>
        </c:if>
    </div>

    <!-- Contexte de la consultation (si intégré depuis le dossier de consultation) -->
    <c:if test="${fromConsultation && not empty consultation}">
        <div class="p-4 rounded-xl bg-indigo-950/40 border border-indigo-500/30 flex flex-wrap items-center justify-between gap-3 text-sm">
            <div class="flex items-center gap-3">
                <span class="text-xl">🩺</span>
                <div>
                    <span class="text-xs text-indigo-300 font-semibold uppercase tracking-wider block">Dossier Patient Associé</span>
                    <strong class="text-white">${consultation.patient.nom} ${consultation.patient.prenom}</strong>
                    <span class="text-slate-400 text-xs">(NSS : ${consultation.patient.numeroSecuriteSociale})</span>
                </div>
            </div>
            <div class="text-right">
                <span class="text-xs text-slate-400 block">Motif de consultation :</span>
                <span class="text-slate-200 font-medium">${consultation.motif}</span>
            </div>
        </div>
    </c:if>

    <!-- Formulaire de recherche et filtrage Stream API -->
    <form action="${pageContext.request.contextPath}/generaliste/recherche-specialiste" method="get" 
          class="p-6 rounded-2xl bg-slate-800/50 border border-slate-700/60 shadow-xl space-y-4">
        
        <c:choose>
            <c:when test="${fromConsultation}">
                <c:if test="${not empty consultationId}">
                    <input type="hidden" name="consultationId" value="${consultationId}" />
                </c:if>
                <input type="hidden" name="fromConsultation" value="true" />
            </c:when>
            <c:otherwise>
                <!-- Sélection du patient en cours (affiché uniquement si non issu de la page consultation) -->
                <div class="p-4 rounded-xl bg-slate-900/60 border border-slate-700 space-y-2">
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider flex items-center gap-1.5">
                        <span>👤</span> Patient associé (Consultation EN_COURS uniquement) <span class="text-rose-400">*</span>
                    </label>
                    <select name="consultationId" id="consultationSelect" required 
                            class="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-700 text-white text-sm focus:outline-none focus:border-indigo-500 transition">
                        <option value="" disabled ${empty consultationId ? 'selected' : ''}>-- Sélectionner un patient ayant une consultation EN_COURS --</option>
                        <c:forEach var="c" items="${consultationsEnCours}">
                            <option value="${c.id}" ${consultationId == c.id ? 'selected' : ''}>
                                ${c.patient.nom} ${c.patient.prenom} (NSS: ${c.patient.numeroSecuriteSociale}) — Motif: ${c.motif}
                            </option>
                        </c:forEach>
                    </select>
                    <p class="text-[11px] text-slate-500 mt-1">Seuls les dossiers EN_COURS sont proposés. Les dossiers EN_ATTENTE_AVIS_SPECIALISTE ont déjà une expertise en cours.</p>
                    <c:if test="${empty consultationsEnCours}">
                        <p class="text-xs text-amber-400 mt-1 flex items-center gap-1">
                            <span>⚠️</span> Aucune consultation EN_COURS. Veuillez d'abord démarrer une consultation depuis votre tableau de bord.
                        </p>
                    </c:if>
                </div>
            </c:otherwise>
        </c:choose>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 items-end">
            <!-- Choix de la spécialité -->
            <div>
                <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                    Spécialité médicale <span class="text-rose-400">*</span>
                </label>
                <select name="specialite" required 
                        class="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-700 text-white text-sm focus:outline-none focus:border-indigo-500 transition">
                    <option value="ALL" ${selectedSpecialite == 'ALL' ? 'selected' : ''}>-- Toutes les spécialités --</option>
                    <c:forEach var="spec" items="${specialitesDisponibles}">
                        <option value="${spec}" ${selectedSpecialite == spec ? 'selected' : ''}>${spec}</option>
                    </c:forEach>
                    <c:if test="${empty specialitesDisponibles}">
                        <option value="Cardiologie" ${selectedSpecialite == 'Cardiologie' ? 'selected' : ''}>Cardiologie</option>
                        <option value="Dermatologie" ${selectedSpecialite == 'Dermatologie' ? 'selected' : ''}>Dermatologie</option>
                        <option value="Neurologie" ${selectedSpecialite == 'Neurologie' ? 'selected' : ''}>Neurologie</option>
                        <option value="Pédiatrie" ${selectedSpecialite == 'Pédiatrie' ? 'selected' : ''}>Pédiatrie</option>
                        <option value="Pneumologie" ${selectedSpecialite == 'Pneumologie' ? 'selected' : ''}>Pneumologie</option>
                        <option value="Ophtalmologie" ${selectedSpecialite == 'Ophtalmologie' ? 'selected' : ''}>Ophtalmologie</option>
                    </c:if>
                </select>
            </div>

            <!-- Tarif max pour filtrage Stream API -->
            <div>
                <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                    Tarif Maximum (DH)
                </label>
                <div class="relative">
                    <input type="number" name="maxTarif" value="${selectedMaxTarif}" step="10" min="0" placeholder="ex: 350" 
                           class="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-700 text-white text-sm focus:outline-none focus:border-indigo-500 transition" />
                    <span class="absolute right-4 top-3 text-xs text-slate-500 font-mono">DH</span>
                </div>
            </div>

            <!-- Bouton Filtrer -->
            <div>
                <button type="submit" 
                        class="w-full py-3 px-6 rounded-xl bg-indigo-600 hover:bg-indigo-500 text-white font-semibold text-sm transition shadow-lg shadow-indigo-600/30 flex items-center justify-center gap-2">
                    <span>⚡</span> Filtrer
                </button>
            </div>
        </div>
    </form>

    <!-- Résultats des spécialistes filtrés -->
    <div class="space-y-4">
        <div class="flex items-center justify-between text-xs text-slate-400">
            <span>
                Résultats triés par tarif croissant (Stream API) : 
                <strong class="text-white">${not empty specialistes ? specialistes.size() : 0} spécialiste(s) trouvé(s)</strong>
            </span>
        </div>

        <c:choose>
            <c:when test="${not empty specialistes}">
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
                    <c:forEach var="s" items="${specialistes}">
                        <div class="p-6 rounded-2xl bg-slate-800/40 border border-slate-700/60 hover:border-indigo-500/50 backdrop-blur-md shadow-lg transition flex flex-col justify-between space-y-4">
                            <div>
                                <div class="flex justify-between items-start mb-2">
                                    <span class="px-2.5 py-1 rounded-full bg-indigo-500/20 text-indigo-300 border border-indigo-500/30 text-xs font-semibold">
                                        ${s.specialite}
                                    </span>
                                    <span class="text-xs text-slate-400">
                                        ⏱ ~${s.dureeMoyenne} min
                                    </span>
                                </div>
                                <h3 class="font-bold text-white text-lg tracking-wide">
                                    Dr. ${s.prenom} ${s.nom}
                                </h3>
                                <p class="text-xs text-slate-400 mt-0.5">${s.email}</p>
                            </div>

                            <div class="pt-4 border-t border-slate-700/60 flex items-center justify-between">
                                <div>
                                    <span class="text-[11px] uppercase tracking-wider text-slate-400 block">Tarif avis</span>
                                    <span class="text-lg font-bold text-emerald-400 font-mono">${s.tarif} DH</span>
                                </div>
                                <a href="${pageContext.request.contextPath}/generaliste/creneaux?specialisteId=${s.id}<c:if test="${not empty consultationId}">&consultationId=${consultationId}</c:if>" 
                                   data-base-href="${pageContext.request.contextPath}/generaliste/creneaux?specialisteId=${s.id}"
                                   class="btn-creneau px-4 py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-semibold transition shadow-md shadow-emerald-600/20 flex items-center gap-1.5">
                                    <span>Voir Créneaux</span> ➔
                                </a>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="p-12 text-center rounded-2xl bg-slate-800/30 border border-dashed border-slate-700/60">
                    <span class="text-3xl block mb-2">🔍</span>
                    <h4 class="text-white font-semibold text-base mb-1">Aucun spécialiste ne correspond à ces critères</h4>
                    <p class="text-slate-400 text-xs max-w-md mx-auto">
                        Veuillez modifier votre filtre de spécialité ou augmenter le tarif maximum recherché.
                    </p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<script>
document.addEventListener("DOMContentLoaded", function () {
    const consultationSelect = document.getElementById("consultationSelect");
    if (consultationSelect) {
        function updateCreneauxLinks() {
            const selectedConsultationId = consultationSelect.value;
            const buttons = document.querySelectorAll(".btn-creneau");
            buttons.forEach(btn => {
                const baseHref = btn.getAttribute("data-base-href");
                if (selectedConsultationId) {
                    btn.href = baseHref + "&consultationId=" + encodeURIComponent(selectedConsultationId);
                } else {
                    btn.href = baseHref;
                }
            });
        }

        consultationSelect.addEventListener("change", updateCreneauxLinks);
        updateCreneauxLinks();

        document.querySelectorAll(".btn-creneau").forEach(btn => {
            btn.addEventListener("click", function (e) {
                if (!consultationSelect.value) {
                    e.preventDefault();
                    consultationSelect.focus();
                    consultationSelect.classList.add("ring-2", "ring-rose-500");
                    alert("Veuillez sélectionner un patient ayant une consultation en cours avant de choisir un créneau.");
                }
            });
        });
    }
});
</script>

<jsp:include page="../templates/footer.jsp" />