<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../templates/header.jsp" />

<div class="max-w-4xl mx-auto space-y-8">
    <!-- En-tête -->
    <div class="flex items-center justify-between border-b border-slate-800 pb-5">
        <div>
            <h1 class="text-2xl font-bold text-white tracking-wide flex items-center gap-2">
                <span>⚙️</span> Configuration du Profil Spécialiste
            </h1>
            <p class="text-sm text-slate-400 mt-1">
                US5 : Définissez votre spécialité médicale, votre tarif par réservation et consultez vos paramètres de télé-expertise.
            </p>
        </div>
        <span class="px-3.5 py-1.5 rounded-xl bg-indigo-500/10 border border-indigo-500/30 text-indigo-400 text-xs font-semibold">
            Dr. ${sessionScope.user.prenom} ${sessionScope.user.nom}
        </span>
    </div>

    <!-- Alertes -->
    <c:if test="${not empty param.msg}">
        <div class="p-4 rounded-xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 text-sm flex items-center gap-2 shadow-lg shadow-emerald-500/5">
            <span>✅</span> <span>${param.msg}</span>
        </div>
    </c:if>
    <c:if test="${not empty param.error}">
        <div class="p-4 rounded-xl bg-rose-500/10 border border-rose-500/30 text-rose-300 text-sm flex items-center gap-2 shadow-lg shadow-rose-500/5">
            <span>⚠️</span> <span>${param.error}</span>
        </div>
    </c:if>

    <!-- Carte Formulaire Profil -->
    <div class="rounded-2xl bg-slate-800/40 border border-slate-700/50 p-8 backdrop-blur-md shadow-xl">
        <form action="${pageContext.request.contextPath}/specialiste/configurer-profil" method="post" class="space-y-6">
            <input type="hidden" name="_csrf" value="${csrfToken}" />

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <!-- Spécialité -->
                <div>
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                        Spécialité Médicale <span class="text-rose-400">*</span>
                    </label>
                    <div class="relative">
                        <select name="specialite" required
                                class="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-700 text-white text-sm focus:outline-none focus:border-indigo-500 transition">
                            <option value="" disabled ${empty specialiste.specialite ? 'selected' : ''}>-- Choisir une spécialité --</option>
                            <option value="Cardiologie" ${specialiste.specialite == 'Cardiologie' ? 'selected' : ''}>Cardiologie</option>
                            <option value="Dermatologie" ${specialiste.specialite == 'Dermatologie' ? 'selected' : ''}>Dermatologie</option>
                            <option value="Endocrinologie" ${specialiste.specialite == 'Endocrinologie' ? 'selected' : ''}>Endocrinologie</option>
                            <option value="Gastro-entérologie" ${specialiste.specialite == 'Gastro-entérologie' ? 'selected' : ''}>Gastro-entérologie</option>
                            <option value="Neurologie" ${specialiste.specialite == 'Neurologie' ? 'selected' : ''}>Neurologie</option>
                            <option value="Ophtalmologie" ${specialiste.specialite == 'Ophtalmologie' ? 'selected' : ''}>Ophtalmologie</option>
                            <option value="Pneumologie" ${specialiste.specialite == 'Pneumologie' ? 'selected' : ''}>Pneumologie</option>
                            <option value="Psychiatrie" ${specialiste.specialite == 'Psychiatrie' ? 'selected' : ''}>Psychiatrie</option>
                            <option value="Rhumatologie" ${specialiste.specialite == 'Rhumatologie' ? 'selected' : ''}>Rhumatologie</option>
                            <c:if test="${not empty specialiste.specialite && 
                                          specialiste.specialite != 'Cardiologie' && 
                                          specialiste.specialite != 'Dermatologie' && 
                                          specialiste.specialite != 'Endocrinologie' && 
                                          specialiste.specialite != 'Gastro-entérologie' && 
                                          specialiste.specialite != 'Neurologie' && 
                                          specialiste.specialite != 'Ophtalmologie' && 
                                          specialiste.specialite != 'Pneumologie' && 
                                          specialiste.specialite != 'Psychiatrie' && 
                                          specialiste.specialite != 'Rhumatologie'}">
                                <option value="${specialiste.specialite}" selected>${specialiste.specialite}</option>
                            </c:if>
                        </select>
                    </div>
                    <p class="text-xs text-slate-500 mt-1.5">Visible par les médecins généralistes lors de l'orientation.</p>
                </div>

                <!-- Tarif par réservation -->
                <div>
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                        Tarif de Télé-expertise (DH) <span class="text-rose-400">*</span>
                    </label>
                    <div class="relative">
                        <input type="number" name="tarif" step="10" min="0" required
                               value="${specialiste.tarif > 0 ? specialiste.tarif : 300.0}"
                               class="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-700 text-white text-sm focus:outline-none focus:border-indigo-500 transition pl-11" />
                        <span class="absolute left-4 top-3.5 text-slate-400 text-sm font-semibold">DH</span>
                    </div>
                    <p class="text-xs text-slate-500 mt-1.5">Montant facturé au dossier patient pour un avis rendu.</p>
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 pt-2">
                <!-- Durée moyenne de consultation (Fixe 30 min) -->
                <div>
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                        Durée moyenne de consultation
                    </label>
                    <div class="relative">
                        <input type="text" value="30 minutes (Fixe)" disabled readonly
                               class="w-full px-4 py-3 rounded-xl bg-slate-900/60 border border-slate-800 text-slate-400 text-sm cursor-not-allowed font-medium pl-10" />
                        <span class="absolute left-3.5 top-3.5 text-indigo-400 text-sm">⏱️</span>
                    </div>
                    <p class="text-xs text-slate-500 mt-1.5 flex items-center gap-1">
                        <span>ℹ️</span> <span>Règle métier US5 : Durée fixe réglementaire fixée à <strong>30 min</strong> par créneau.</span>
                    </p>
                </div>

                <!-- Email professionnel -->
                <div>
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                        Compte Spécialiste
                    </label>
                    <input type="text" value="${sessionScope.user.email}" disabled readonly
                           class="w-full px-4 py-3 rounded-xl bg-slate-900/60 border border-slate-800 text-slate-400 text-sm cursor-not-allowed" />
                    <p class="text-xs text-slate-500 mt-1.5">Identifiant de connexion.</p>
                </div>
            </div>

            <!-- Bouton d'action -->
            <div class="flex items-center justify-between pt-6 border-t border-slate-700/50">
                <a href="${pageContext.request.contextPath}/specialiste/dashboard" 
                   class="px-5 py-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 text-sm font-semibold transition">
                    ← Retour au tableau de bord
                </a>

                <button type="submit" 
                        class="px-6 py-3 rounded-xl bg-indigo-600 hover:bg-indigo-500 text-white text-sm font-semibold shadow-lg shadow-indigo-600/30 transition flex items-center gap-2">
                    <span>💾</span> Enregistrer les modifications
                </button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="../templates/footer.jsp" />
