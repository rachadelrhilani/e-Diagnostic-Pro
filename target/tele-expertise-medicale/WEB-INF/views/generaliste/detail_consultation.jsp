<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <jsp:include page="../templates/header.jsp" />

        <div class="max-w-6xl mx-auto space-y-8">
            <!-- En-tête -->
            <div class="flex flex-col md:flex-row md:items-center justify-between border-b border-slate-800 pb-5 gap-4">
                <div>
                    <div class="flex items-center gap-3">
                        <h2 class="text-2xl font-bold text-white tracking-wide">Dossier de Consultation
                            #${consultation.id}</h2>
                        <c:choose>
                            <c:when test="${consultation.statut == 'EN_COURS'}">
                                <span
                                    class="px-3 py-1 rounded-full text-xs font-semibold bg-amber-500/20 text-amber-300 border border-amber-500/30">
                                    En cours
                                </span>
                            </c:when>
                            <c:when test="${consultation.statut == 'EN_ATTENTE_AVIS_SPECIALISTE'}">
                                <span
                                    class="px-3 py-1 rounded-full text-xs font-semibold bg-purple-500/20 text-purple-300 border border-purple-500/30">
                                    En attente avis spécialiste
                                </span>
                            </c:when>
                            <c:when test="${consultation.statut == 'TERMINEE'}">
                                <span
                                    class="px-3 py-1 rounded-full text-xs font-semibold bg-emerald-500/20 text-emerald-300 border border-emerald-500/30">
                                    Consultation clôturée
                                </span>
                            </c:when>
                        </c:choose>
                    </div>
                    <p class="text-xs text-slate-400 mt-1">
                        Consultation ouverte le ${consultation.dateConsultation} par Dr.
                        ${consultation.generaliste.prenom} ${consultation.generaliste.nom}
                    </p>
                </div>

                <div class="flex items-center gap-3">
                    <a href="${pageContext.request.contextPath}/generaliste/dashboard"
                        class="px-4 py-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 text-xs font-semibold border border-slate-700 transition">
                        ⬅ Retour au tableau de bord
                    </a>
                </div>
            </div>

            <!-- Alertes -->
            <c:if test="${not empty param.msg}">
                <div
                    class="p-4 rounded-xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 text-sm flex items-center gap-2 shadow-lg shadow-emerald-500/5">
                    <span>✅</span> <span>${param.msg}</span>
                </div>
            </c:if>
            <c:if test="${not empty param.error}">
                <div
                    class="p-4 rounded-xl bg-rose-500/10 border border-rose-500/30 text-rose-300 text-sm flex items-center gap-2 shadow-lg shadow-rose-500/5">
                    <span>⚠️</span> <span>${param.error}</span>
                </div>
            </c:if>

            <!-- US4 : SECTION COÛT TOTAL (Lambda map().sum()) -->
            <div
                class="p-6 rounded-2xl bg-gradient-to-br from-slate-800/90 to-slate-900 border border-emerald-500/30 shadow-2xl space-y-4">
                <div
                    class="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-slate-700/60 pb-4">
                    <div class="flex items-center gap-3">
                        <div
                            class="w-10 h-10 rounded-xl bg-emerald-500/20 border border-emerald-500/30 flex items-center justify-center text-emerald-400 font-bold text-lg">
                            💰
                        </div>
                        <div>
                            <div class="flex items-center gap-2">
                                <span
                                    class="px-2 py-0.5 rounded bg-emerald-500/20 text-emerald-300 text-[10px] font-bold uppercase tracking-wider">
                                    US4 : Facturation
                                </span>
                                <h3 class="text-lg font-bold text-white">Coût Total de la Prise en Charge</h3>
                            </div>
                            <p class="text-xs text-slate-400">
                                Calculé par expression Lambda Stream API :
                                <code>coutBase + tarifExpertise + actes.map().sum()</code>
                            </p>
                        </div>
                    </div>

                    <!-- Badge Montant Global -->
                    <div class="px-5 py-3 rounded-2xl bg-emerald-500/10 border border-emerald-500/40 text-right">
                        <span class="text-[11px] uppercase tracking-wider text-slate-400 font-semibold block">Total à
                            régler</span>
                        <span class="text-3xl font-extrabold text-emerald-400 font-mono tracking-tight">${coutTotal}
                            DH</span>
                    </div>
                </div>

                <!-- Décomposition du coût (US4) -->
                <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 pt-1">
                    <!-- 1. Consultation de base -->
                    <div class="p-4 rounded-xl bg-slate-800/50 border border-slate-700/50">
                        <span class="text-[11px] text-slate-400 uppercase tracking-wider font-semibold block">1.
                            Consultation Générale</span>
                        <span class="text-xl font-bold text-white font-mono mt-1 block">150.00 DH</span>
                        <span class="text-[11px] text-slate-400">Tarif fixe réglementaire (US1)</span>
                    </div>

                    <!-- 2. Demande d'expertise -->
                    <div class="p-4 rounded-xl bg-slate-800/50 border border-slate-700/50">
                        <span class="text-[11px] text-slate-400 uppercase tracking-wider font-semibold block">2.
                            Télé-Expertise Spécialiste</span>
                        <span class="text-xl font-bold text-white font-mono mt-1 block">${consultation.tarifExpertise}
                            DH</span>
                        <span class="text-[11px] text-slate-400">
                            <c:choose>
                                <c:when test="${consultation.tarifExpertise > 0}">
                                    Dr. ${consultation.demandeExpertise.specialiste.nom}
                                    (${consultation.demandeExpertise.specialiste.specialite})
                                </c:when>
                                <c:otherwise>
                                    Aucune expertise demandée
                                </c:otherwise>
                            </c:choose>
                        </span>
                    </div>

                    <!-- 3. Actes techniques -->
                    <div class="p-4 rounded-xl bg-slate-800/50 border border-slate-700/50">
                        <span class="text-[11px] text-slate-400 uppercase tracking-wider font-semibold block">3. Actes
                            Techniques Médicaux</span>
                        <span
                            class="text-xl font-bold text-white font-mono mt-1 block">${consultation.totalActesMedicaux}
                            DH</span>
                        <span class="text-[11px] text-slate-400">
                            ${not empty consultation.actesMedicaux ? consultation.actesMedicaux.size() : 0} acte(s)
                            réalisé(s)
                        </span>
                    </div>
                </div>
            </div>

            <!-- Informations Patient & Signes Vitaux (US1) -->
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <!-- Informations Patient -->
                <div class="p-6 rounded-2xl bg-slate-800/40 border border-slate-700/60 backdrop-blur-md space-y-4">
                    <h3 class="text-sm font-bold text-white uppercase tracking-wider flex items-center gap-2">
                        <span>👤</span> Données du Patient
                    </h3>
                    <div class="space-y-3 text-sm">
                        <div>
                            <span class="text-xs text-slate-400 block">Identité :</span>
                            <strong class="text-white text-base">${consultation.patient.nom}
                                ${consultation.patient.prenom}</strong>
                        </div>
                        <div>
                            <span class="text-xs text-slate-400 block">N° Sécurité Sociale :</span>
                            <span
                                class="text-slate-200 font-mono text-xs">${consultation.patient.numeroSecuriteSociale}</span>
                        </div>
                        <div>
                            <span class="text-xs text-slate-400 block">Date de Naissance :</span>
                            <span class="text-slate-200">${consultation.patient.dateNaissance != null ?
                                consultation.patient.dateNaissance : 'Non renseignée'}</span>
                        </div>
                        <div>
                            <span class="text-xs text-slate-400 block">Mutuelle :</span>
                            <span class="text-slate-200">${consultation.patient.mutuelle != null ?
                                consultation.patient.mutuelle : 'Aucune'}</span>
                        </div>
                        <div>
                            <span class="text-xs text-slate-400 block">Téléphone :</span>
                            <span class="text-slate-200">${consultation.patient.telephone != null ?
                                consultation.patient.telephone : 'Non renseigné'}</span>
                        </div>
                    </div>
                </div>

                <!-- Signes Vitaux & Antécédents -->
                <div class="p-6 rounded-2xl bg-slate-800/40 border border-slate-700/60 backdrop-blur-md space-y-4">
                    <h3 class="text-sm font-bold text-white uppercase tracking-wider flex items-center gap-2">
                        <span>💓</span> Dernières Constantes (Infirmier)
                    </h3>
                    <c:choose>
                        <c:when test="${not empty consultation.patient.signesVitaux}">
                            <c:set var="sv"
                                value="${consultation.patient.signesVitaux[consultation.patient.signesVitaux.size() - 1]}" />
                            <div class="grid grid-cols-2 gap-3 text-xs">
                                <div class="p-2.5 rounded-lg bg-slate-900/60 border border-slate-700/40">
                                    <span class="text-slate-400 block">Tension Artérielle</span>
                                    <span class="text-white font-bold font-mono text-sm">${sv.tensionArterielle != null
                                        ? sv.tensionArterielle : '-'}</span>
                                </div>
                                <div class="p-2.5 rounded-lg bg-slate-900/60 border border-slate-700/40">
                                    <span class="text-slate-400 block">Fréquence Cardiaque</span>
                                    <span class="text-white font-bold font-mono text-sm">${sv.frequenceCardiaque != null
                                        ? sv.frequenceCardiaque : '-'} bpm</span>
                                </div>
                                <div class="p-2.5 rounded-lg bg-slate-900/60 border border-slate-700/40">
                                    <span class="text-slate-400 block">Température</span>
                                    <span class="text-white font-bold font-mono text-sm">${sv.temperature != null ?
                                        sv.temperature : '-'} °C</span>
                                </div>
                                <div class="p-2.5 rounded-lg bg-slate-900/60 border border-slate-700/40">
                                    <span class="text-slate-400 block">Poids / Taille</span>
                                    <span class="text-white font-bold font-mono text-sm">${sv.poids != null ? sv.poids :
                                        '-'} kg / ${sv.taille != null ? sv.taille : '-'} m</span>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <p class="text-xs text-slate-400 italic">Aucune constante vitale enregistrée pour ce
                                patient.</p>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Motif & Observations initiales (US1) -->
                <div class="p-6 rounded-2xl bg-slate-800/40 border border-slate-700/60 backdrop-blur-md space-y-4">
                    <h3 class="text-sm font-bold text-white uppercase tracking-wider flex items-center gap-2">
                        <span>📝</span> Motif & Observations
                    </h3>
                    <div class="space-y-3 text-sm">
                        <div>
                            <span class="text-xs text-slate-400 uppercase tracking-wider font-semibold block">Motif de
                                consultation :</span>
                            <p class="text-white font-medium mt-1">${consultation.motif}</p>
                        </div>
                        <div>
                            <span
                                class="text-xs text-slate-400 uppercase tracking-wider font-semibold block">Observations
                                saisies :</span>
                            <p class="text-slate-300 text-xs mt-1 leading-relaxed">
                                ${not empty consultation.observations ? consultation.observations : 'Aucune observation
                                saisie.'}
                            </p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- US4 : Section Actes Techniques Médicaux -->
            <div class="p-6 rounded-2xl bg-slate-800/40 border border-slate-700/50 space-y-6">
                <div class="flex items-center justify-between">
                    <div>
                        <h3 class="text-base font-bold text-white flex items-center gap-2">
                            <span>🔬</span> Actes Techniques Médicaux (US4)
                        </h3>
                        <p class="text-xs text-slate-400">ECG, Bilan sanguin, Radiographie... Chaque acte est intégré au
                            calcul du coût total</p>
                    </div>
                    <span class="text-sm font-bold text-emerald-400 font-mono">
                        Total Actes : ${consultation.totalActesMedicaux} DH
                    </span>
                </div>

                <!-- Liste des actes existants -->
                <c:choose>
                    <c:when test="${not empty consultation.actesMedicaux}">
                        <div class="overflow-x-auto">
                            <table class="w-full text-left text-sm text-slate-300">
                                <thead
                                    class="text-xs uppercase bg-slate-900/60 text-slate-400 border-b border-slate-700">
                                    <tr>
                                        <th class="px-4 py-3 rounded-l-xl">Acte Technique</th>
                                        <th class="px-4 py-3 text-right rounded-r-xl">Tarif (DH)</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-slate-800">
                                    <c:forEach var="acte" items="${consultation.actesMedicaux}">
                                        <tr class="hover:bg-slate-800/30">
                                            <td class="px-4 py-3 text-white font-medium flex items-center gap-2">
                                                <span>•</span> ${acte.nom}
                                            </td>
                                            <td class="px-4 py-3 text-right font-mono font-bold text-emerald-400">
                                                ${acte.tarif} DH
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div
                            class="p-4 rounded-xl bg-slate-900/30 border border-slate-700/40 text-center text-xs text-slate-400">
                            Aucun acte technique n'a encore été ajouté à cette consultation.
                        </div>
                    </c:otherwise>
                </c:choose>

                <!-- Formulaire d'ajout d'acte -->
                <c:if test="${consultation.statut != 'TERMINEE'}">
                    <form action="${pageContext.request.contextPath}/generaliste/ajouter-acte" method="post"
                        class="pt-4 border-t border-slate-700/50 flex flex-col sm:flex-row gap-3 items-end">
                        <input type="hidden" name="_csrf" value="${csrfToken}" />
                        <input type="hidden" name="consultationId" value="${consultation.id}" />

                        <div class="flex-1 w-full">
                            <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
                                Nom de l'acte technique
                            </label>
                            <input type="text" name="nomActe" required
                                placeholder="Ex : Électrocardiogramme (ECG), Radiographie, Bilan bio..."
                                list="suggestionsActes"
                                class="w-full px-4 py-2.5 rounded-xl bg-slate-900 border border-slate-700 text-white text-sm focus:outline-none focus:border-indigo-500 transition" />
                            <datalist id="suggestionsActes">
                                <option value="Électrocardiogramme (ECG)">
                                <option value="Radiographie thoracique">
                                <option value="Prélèvement sanguin / Bilan complet">
                                <option value="Glycémie capillaire">
                                <option value="Échographie abdominale">
                            </datalist>
                        </div>

                        <div class="w-full sm:w-44">
                            <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
                                Tarif (DH)
                            </label>
                            <input type="number" step="0.1" min="0" name="tarifActe" required placeholder="ex: 120"
                                class="w-full px-4 py-2.5 rounded-xl bg-slate-900 border border-slate-700 text-white text-sm focus:outline-none focus:border-indigo-500 transition font-mono" />
                        </div>

                        <button type="submit"
                            class="w-full sm:w-auto px-6 py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white font-semibold text-xs transition shadow-lg shadow-emerald-600/30 whitespace-nowrap">
                            ➕ Ajouter l'Acte
                        </button>
                    </form>
                </c:if>
            </div>

            <!-- US3 : Section Demande de Télé-Expertise -->
            <div class="p-6 rounded-2xl bg-slate-800/40 border border-slate-700/50 space-y-4">
                <div class="flex items-center justify-between">
                    <h3 class="text-base font-bold text-white flex items-center gap-2">
                        <span>👨‍⚕️</span> Télé-Expertise Médicale (US3)
                    </h3>
                </div>

                <c:choose>
                    <c:when test="${not empty consultation.demandeExpertise}">
                        <!-- Détail de la demande existante -->
                        <div class="p-5 rounded-xl bg-slate-900/60 border border-indigo-500/30 space-y-4">
                            <div
                                class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 border-b border-slate-700/60 pb-3">
                                <div>
                                    <span
                                        class="text-xs text-indigo-400 font-semibold uppercase tracking-wider block">Spécialiste
                                        Sollicité</span>
                                    <h4 class="text-base font-bold text-white">
                                        Dr. ${consultation.demandeExpertise.specialiste.prenom}
                                        ${consultation.demandeExpertise.specialiste.nom}
                                        <span
                                            class="text-xs text-indigo-300 font-normal">(${consultation.demandeExpertise.specialiste.specialite})</span>
                                    </h4>
                                </div>
                                <div class="flex items-center gap-2">
                                    <span
                                        class="px-2.5 py-1 rounded-full text-xs font-semibold 
                                ${consultation.demandeExpertise.statut == 'TERMINEE' ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/30' : 'bg-purple-500/20 text-purple-300 border border-purple-500/30'}">
                                        ${consultation.demandeExpertise.statut}
                                    </span>
                                    <span
                                        class="px-2.5 py-1 rounded-full text-xs font-semibold bg-slate-700 text-slate-300 border border-slate-600">
                                        Priorité : ${consultation.demandeExpertise.priorite}
                                    </span>
                                </div>
                            </div>

                            <div class="text-xs space-y-2">
                                <div>
                                    <span class="text-slate-400 font-semibold block uppercase tracking-wider">Créneau
                                        réservé :</span>
                                    <span class="text-white font-mono">
                                        ${consultation.demandeExpertise.creneau.heureDebut.toLocalDate()}
                                        de ${consultation.demandeExpertise.creneau.heureDebut.toLocalTime()} à
                                        ${consultation.demandeExpertise.creneau.heureFin.toLocalTime()}
                                    </span>
                                </div>
                                <div>
                                    <span class="text-slate-400 font-semibold block uppercase tracking-wider">Question
                                        clinique & Analyses transmises :</span>
                                    <p
                                        class="text-slate-200 bg-slate-800/80 p-3 rounded-lg mt-1 whitespace-pre-line border border-slate-700/60">
                                        ${consultation.demandeExpertise.question}
                                    </p>
                                </div>
                            </div>

                            <!-- Avis rendu par le spécialiste -->
                            <c:if test="${consultation.demandeExpertise.statut == 'TERMINEE'}">
                                <div
                                    class="mt-4 p-4 rounded-xl bg-emerald-500/10 border border-emerald-500/30 space-y-2">
                                    <span class="text-xs font-bold text-emerald-300 uppercase tracking-wider block">
                                        🩺 Avis Médical du Spécialiste (${consultation.demandeExpertise.dateReponse}) :
                                    </span>
                                    <p class="text-sm text-white whitespace-pre-line">
                                        ${consultation.demandeExpertise.avisMedical}</p>

                                    <c:if test="${not empty consultation.demandeExpertise.recommandations}">
                                        <span
                                            class="text-xs font-bold text-emerald-300 uppercase tracking-wider block pt-2">
                                            💡 Recommandations et Prescription :
                                        </span>
                                        <p class="text-sm text-slate-200 whitespace-pre-line">
                                            ${consultation.demandeExpertise.recommandations}</p>
                                    </c:if>
                                </div>
                            </c:if>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div
                            class="p-6 rounded-xl bg-slate-900/40 border border-slate-700/50 flex flex-col sm:flex-row items-center justify-between gap-4">
                            <div>
                                <h4 class="text-white font-semibold text-sm">Besoin de l'expertise d'un spécialiste ?
                                </h4>
                                <p class="text-xs text-slate-400 mt-0.5">
                                    Filtrez les spécialistes par spécialité et tarif via Stream API, choisissez un
                                    créneau disponible et posez votre question.
                                </p>
                            </div>
                            <a href="${pageContext.request.contextPath}/generaliste/recherche-specialiste?consultationId=${consultation.id}&fromConsultation=true"
                                class="px-5 py-2.5 rounded-xl bg-indigo-600 hover:bg-indigo-500 text-white font-semibold text-xs transition shadow-lg shadow-indigo-600/30 whitespace-nowrap flex items-center gap-2">
                                <span>🔍</span> Demander un Avis Spécialisé ➔
                            </a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- US1 / Finalisation : Clôture de la Consultation Directe -->
            <div class="p-6 rounded-2xl bg-slate-800/40 border border-slate-700/50 space-y-4">
                <h3 class="text-base font-bold text-white flex items-center gap-2">
                    <span>🏁</span> Conclusion & Clôture de la Consultation
                </h3>

                <c:choose>
                    <c:when test="${consultation.statut == 'TERMINEE'}">
                        <div class="p-5 rounded-xl bg-slate-900/60 border border-slate-700/60 space-y-3">
                            <div class="flex items-center gap-2 text-emerald-400 text-xs font-bold">
                                <span>✓</span> Consultation terminée et clôturée.
                            </div>
                            <div>
                                <span
                                    class="text-xs text-slate-400 uppercase tracking-wider font-semibold block">Diagnostic
                                    final :</span>
                                <p class="text-white text-sm font-medium mt-1">${consultation.diagnostic}</p>
                            </div>
                            <div>
                                <span
                                    class="text-xs text-slate-400 uppercase tracking-wider font-semibold block">Traitement
                                    prescrit :</span>
                                <p class="text-slate-200 text-sm mt-1 whitespace-pre-line">${consultation.traitement}
                                </p>
                            </div>
                        </div>
                    </c:when>
                    <c:when test="${consultation.statut == 'EN_ATTENTE_AVIS_SPECIALISTE'}">
                        <div class="p-5 rounded-xl bg-purple-500/10 border border-purple-500/30 space-y-3">
                            <div class="flex items-center gap-2 text-purple-300 text-xs font-bold">
                                <span>⏳</span> Demande de télé-expertise en cours.
                            </div>
                            <p class="text-slate-300 text-sm">
                                Une demande d'expertise a été transmise au médecin spécialiste. Vous ne pouvez pas
                                clôturer la consultation tant que le spécialiste n'a pas rendu son avis.
                            </p>
                            <c:if test="${not empty consultation.demandeExpertise}">
                                <div class="p-3 rounded-lg bg-slate-900/80 text-xs text-slate-400 space-y-1">
                                    <p><strong class="text-slate-200">Spécialiste sollicité :</strong> Dr.
                                        ${consultation.demandeExpertise.specialiste.nom}
                                        ${consultation.demandeExpertise.specialiste.prenom}</p>
                                    <p><strong class="text-slate-200">Spécialité :</strong>
                                        ${consultation.demandeExpertise.specialiste.specialite}</p>
                                </div>
                            </c:if>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <form action="${pageContext.request.contextPath}/generaliste/cloturer-directe" method="post"
                            class="space-y-4">
                            <input type="hidden" name="_csrf" value="${csrfToken}" />
                            <input type="hidden" name="consultationId" value="${consultation.id}" />

                            <div>
                                <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                                    Diagnostic Médical <span class="text-rose-400">*</span>
                                </label>
                                <input type="text" name="diagnostic" required value="${consultation.diagnostic}"
                                    placeholder="Ex : Céphalée de tension, Hypertension artérielle de stade 1..."
                                    class="w-full px-4 py-2.5 rounded-xl bg-slate-900 border border-slate-700 text-white text-sm focus:outline-none focus:border-indigo-500 transition" />
                            </div>

                            <div>
                                <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                                    Traitement Prescrit & Conduite à tenir <span class="text-rose-400">*</span>
                                </label>
                                <textarea name="traitement" rows="3" required
                                    placeholder="Prescription médicamenteuse, posologie, repos, surveillance..."
                                    class="w-full px-4 py-2.5 rounded-xl bg-slate-900 border border-slate-700 text-white text-sm focus:outline-none focus:border-indigo-500 transition">${consultation.traitement}</textarea>
                            </div>

                            <div class="flex justify-between items-center pt-2">
                                <c:if test="${empty consultation.demandeExpertise}">
                                    <a href="${pageContext.request.contextPath}/generaliste/recherche-specialiste?consultationId=${consultation.id}&fromConsultation=true"
                                        class="px-4 py-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 text-xs font-semibold border border-slate-700 transition">
                                        🔍 Demander d'abord un avis spécialiste
                                    </a>
                                </c:if>
                                <button type="submit"
                                    class="ml-auto px-6 py-2.5 rounded-xl bg-rose-600 hover:bg-rose-500 text-white font-semibold text-sm transition shadow-lg shadow-rose-600/30 flex items-center gap-2">
                                    <span>🏁</span> Clôturer Définitivement la Consultation
                                </button>
                            </div>
                        </form>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <jsp:include page="../templates/footer.jsp" />