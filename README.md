# Télé-Expertise Médicale

Application web Java Jakarta EE de **télé-expertise médicale** : un médecin généraliste sollicite l'avis d'un médecin spécialiste sur un créneau réservé, avec calcul du coût total de prise en charge.

## Sommaire

1. [Fonctionnalités](#1-fonctionnalités)
2. [Stack technique](#2-stack-technique)
3. [Prérequis](#3-prérequis)
4. [Installation base de données](#4-installation-base-de-données)
5. [Configuration JPA](#5-configuration-jpa)
6. [Build & exécution](#6-build--exécution)
7. [Comptes & accès](#7-comptes--accès)
8. [Règles métier clés](#8-règles-métier-clés)
9. [Routes (Servlets)](#9-routes-servlets)
10. [Structure du projet](#10-structure-du-projet)
11. [Tests](#11-tests)
12. [Sécurité](#12-sécurité)

---

## 1. Fonctionnalités

### Infirmier (`/infirmier/*`)
- Recherche patient par **NSS** (`/rechercher-patient`).
  - Si le patient a déjà une consultation `EN_COURS` ou `EN_ATTENTE_AVIS_SPECIALISTE` : bandeau 🔒 « Patient déjà en consultation » (formulaire masqué).
- Prise des **signes vitaux** (`/ajouter-signes`) et création nouveau patient (`/creer-patient`).
- Dashboard file d'attente avec filtre par date (`getPatientsParDate`, Stream API + tri chrono).
- Placement en file d'attente (`/envoyer-file-dattente`) : choix du généraliste.
  - Bloqué si le patient a déjà une consultation active.
  - Bloqué si le généraliste choisi a déjà une consultation `EN_COURS` (généralistes occupés grisés dans la liste).

### Généraliste (`/generaliste/*`)
- **US1** : créer une consultation (coût fixe **150 DH**). Un seul dossier `EN_COURS` à la fois par généraliste (une consultation `EN_ATTENTE_AVIS` ne bloque pas).
- Tableau de bord : liste active (`EN_COURS` + `EN_ATTENTE_AVIS`), blocage du formulaire uniquement sur `EN_COURS`.
- **US3** : recherche spécialiste avec filtres Stream API (spécialité + tarif max, tri croissant), page `/recherche-specialiste` **limitée aux consultations `EN_COURS`** (les dossiers en attente d'avis sont exclus).
- Choix créneau (`/creneaux`), envoi demande d'expertise (`/envoyer-demande-expertise` : question + données cliniques + priorité).
- **US4** : actes médicaux (`/ajouter-acte`), coût total = `coutBase + tarifExpertise + actes.map().sum()` (Lambda).
- Clôture directe (`/cloturer-directe` : diagnostic + traitement → `TERMINEE`). Interdite tant qu'une expertise est en attente (voir `detail_consultation.jsp`).

### Spécialiste (`/specialiste/*`)
- **US5** : configurer profil (spécialité, tarif, durée fixe 30 min).
- **US6** : gérer disponibilités : grille journalière par tranches de 30 min (08:00–11:30, 14:00–17:30), créneaux passés désactivés/archivés (`archiverCreneauxPasses`), suppression si `DISPONIBLE`.
- **US7** : dashboard demandes reçues + filtres Stream API (statut, priorité), KPIs, dossier complet (patient, signes vitaux, question).
- **US8** : répondre à l'expertise (avis + recommandations → demande `TERMINEE` **et consultation auto `TERMINEE`**).
- **Annulation** (`/annuler-expertise`) : demande `EN_ATTENTE` ou `TERMINEE` → `ANNULEE`, **créneau auto `DISPONIBLE`**, consultation rouverte en `EN_COURS`. Boutons « Refuser / Annuler » et « Annuler cet avis » sur `expertise.jsp`.

## 2. Stack technique

| Couche | Techno |
|---|---|
| Langage | Java 17 |
| Web | Jakarta EE 10 (Servlets, JSP + JSTL, Sessions), packaging WAR |
| Persistance | JPA 3 / Hibernate 6.4.4 (`RESOURCE_LOCAL`), MySQL 8 (`mysql-connector-j` 8.3.0) |
| Sécurité | BCrypt (`at.favre.lib:bcrypt`), `AuthFilter` (RBAC), `CSRFFilter` |
| UI | JSP + Tailwind (classes utilitaires), header/footer partagés |
| Build | Maven (`maven-compiler`, `maven-war`, `maven-surefire`) |
| Tests | JUnit 5 + Mockito |

## 3. Prérequis

- JDK 17+
- Maven 3.8+
- MySQL 8 (ou compatible)
- Serveur Jakarta EE 10 : **Apache Tomcat 10.1+** (recommandé)

## 4. Installation base de données

```bash
mysql -u root -p -e "CREATE DATABASE tele_expertise_db CHARACTER SET utf8mb4;"
mysql -u root -p tele_expertise_db < tele_expertise_db.sql
```

Le script crée les tables : `utilisateurs`, `infirmiers`, `generalistes`, `specialistes`, `patients`, `signes_vitaux`, `consultations`, `creneaux`, `demandes_expertise`, `actes_medicaux` (+ FK, uniques sur `patients.numero_securite_sociale`, `utilisateurs.email`, `demandes_expertise.consultation_id` / `creneau_id`).

> Utilisateurs de démo : à insérer manuellement (mots de passe **hachés BCrypt** via `PasswordUtil`). Exemple :
> ```sql
> INSERT INTO utilisateurs (nom, prenom, email, password, role) VALUES
>  ('DIALLO','Aminata','inf@med.ma','<hash>','INFIRMIER'),
>  ('BENALI','Karim','gen@med.ma','<hash>','GENERALISTE'),
>  ('ALAMI','Hassan','spe@med.ma','<hash>','SPECIALISTE');
> INSERT INTO infirmiers (id) VALUES (1);
> INSERT INTO generalistes (id) VALUES (2);
> INSERT INTO specialistes (id, specialite, tarif, duree_moyenne) VALUES (3,'Cardiologie',350,30);
> ```

## 5. Configuration JPA

Fichier : `src/main/resources/META-INF/persistence.xml` (unité `teleExpertisePU`).

```xml
<property name="jakarta.persistence.jdbc.url" value="jdbc:mysql://localhost:3306/tele_expertise_db?useSSL=false&amp;serverTimezone=UTC"/>
<property name="jakarta.persistence.jdbc.user" value="root"/>
<property name="jakarta.persistence.jdbc.password" value=""/>
<property name="hibernate.hbm2ddl.auto" value="validate"/>
```

Adapter `user` / `password` à votre MySQL. `JPAUtil` fournit l'`EntityManager`.

## 6. Build & exécution

```bash
# Compilation
mvn clean compile -DskipTests

# Tests
mvn test

# WAR : target/tele-expertise-medicale.war
mvn clean package -DskipTests
```

Déployer le WAR sur Tomcat 10.1 (`webapps/`), puis ouvrir :

```
http://localhost:8080/tele-expertise-medicale/auth/login
```

## 7. Comptes & accès

- Login : `/auth/login` (session `user`, `AuthService` + BCrypt).
- `AuthFilter` (`/*`) : `/auth/*` et `/assets/*` publics, sinon session requise + contrôle RBAC :
  - `/infirmier/*` → `INFIRMIER` (ou `ADMINISTRATEUR`)
  - `/generaliste/*` → `GENERALISTE` (ou `ADMINISTRATEUR`)
  - `/specialiste/*` → `SPECIALISTE` (ou `ADMINISTRATEUR`)

## 8. Règles métier clés

| Règle | Implémentation |
|---|---|
| Consultation : 150 DH fixe | `ConsultationDao.creerConsultation` |
| 1 seul `EN_COURS` par généraliste (attente avis ne bloque pas) | `GeneralisteService.creerConsultation` + `findConsultationsEnCoursStrictParGeneraliste` |
| Recherche spécialiste : que `EN_COURS` | `GeneralisteServlet:/recherche-specialiste` |
| Infirmier : patient déjà actif → affiché « en cours », non réassigné | `findConsultationActiveParPatient`, `InfirmierServlet:/rechercher-patient`, `form_signes_vitaux.jsp` |
| Infirmier : généraliste avec `EN_COURS` → assignation refusée (+ option grisée) | `InfirmierService.envoyerVersFileDattente`, `getIdsGeneralistesOccupes` |
| Demande expertise → consultation `EN_ATTENTE_AVIS` + créneau `RESERVE` | `DemandeExpertiseDao.envoyerDemandeExpertise` |
| Réponse spécialiste → demande `TERMINEE` + consultation auto `TERMINEE` | `DemandeExpertiseDao.repondreAExpertise` |
| Annulation avis/demande → `ANNULEE` + créneau auto `DISPONIBLE` + consultation `EN_COURS` | `DemandeExpertiseDao.annulerDemandeExpertise/annulerAvis` |
| Créneaux : tranches 30 min, passés désactivés/archivés | `SpecialisteService.PLAGES_HORAIRES`, `CreneauDao.archiverCreneauxPasses` |

Statuts : `StatutConsultation` (`EN_COURS`, `EN_ATTENTE_AVIS_SPECIALISTE`, `TERMINEE`), `StatutExpertise` (`EN_ATTENTE`, `TERMINEE`, `ANNULEE`), `StatutCreneau` (`DISPONIBLE`, `RESERVE`, `INDISPONIBLE`, `ARCHIVE`).

## 9. Routes (Servlets)

| Servlet | GET | POST |
|---|---|---|
| `AuthServlet` (`/auth/*`) | `/login` | `/login`, `/logout` |
| `InfirmierServlet` (`/infirmier/*`) | `/dashboard`, `/patients`, `/recherche` | `/rechercher-patient`, `/ajouter-signes`, `/creer-patient`, `/envoyer-file-dattente` |
| `GeneralisteServlet` (`/generaliste/*`) | `/dashboard`, `/recherche-specialiste`, `/creneaux`, `/detail-consultation`, `/consultation` | `/creer-consultation`, `/cloturer-directe`, `/envoyer-demande-expertise`, `/ajouter-acte` |
| `SpecialisteServlet` (`/specialiste/*`) | `/dashboard`, `/demandes`, `/expertise`, `/creneaux`, `/profil` | `/configurer-profil`, `/creer-disponibilites`, `/annuler-creneau`, `/annuler-expertise`, `/repondre-expertise` |

Vues : `src/main/webapp/WEB-INF/views/{auth,infirmier,generaliste,specialiste,templates}/`.

## 10. Structure du projet

```
├── pom.xml
├── tele_expertise_db.sql
├── Diagramme_classe.drawio
└── src/
    ├── main/
    │   ├── java/com/teleexpertise/
    │   │   ├── controller/  (Auth, Infirmier, Generaliste, Specialiste servlets)
    │   │   ├── service/     (Auth, Infirmier, Generaliste, Specialiste)
    │   │   ├── dao/         (GenericDao, Patient, Consultation, Creneau, DemandeExpertise, ...)
    │   │   ├── model/       (Utilisateur, Patient, Consultation, Creneau, DemandeExpertise, enums ...)
    │   │   ├── dto/         (CreneauHoraireDTO)
    │   │   ├── filter/      (AuthFilter, CSRFFilter)
    │   │   └── util/        (JPAUtil, PasswordUtil)
    │   ├── resources/META-INF/persistence.xml
    │   └── webapp/WEB-INF/views/
    └── test/java/com/teleexpertise/service/
        ├── InfirmierServiceTest.java
        ├── GeneralisteServiceTest.java
        └── SpecialisteServiceTest.java
```

## 11. Tests

```bash
mvn test
```

12 tests (JUnit 5 + Mockito) : filtrage Stream API spécialistes/patients, `coutTotal` via Lambda `map().sum()`, création consultation, demande expertise, archivage créneaux, profil spécialiste.

## 12. Sécurité

- Mots de passe hachés BCrypt (`PasswordUtil`), jamais en clair.
- `AuthFilter` : session + RBAC par rôle.
- `CSRFFilter` : token `_csrf` / `csrfToken` sur les formulaires POST.
- `hbm2ddl.auto=validate` : Hibernate ne modifie pas le schéma prod.
