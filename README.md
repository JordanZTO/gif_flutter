# 🎬 Gif Flutter

Aplicativo Flutter que exibe **GIFs aleatórios** da API do [Giphy](https://developers.giphy.com/), com suporte a **favoritos**, **histórico de busca**, **configurações de preferências do usuário** e **tema escuro**.

---

## 🎯 Objetivos de Aprendizagem

* Organizar o código em **camadas**: `services`, `repository`, `theme` e `ui`.
* Melhorar a **experiência do usuário**:

  * Busca com **debounce** e histórico.
  * Estados de **carregamento**, **erro** e **vazio**.
  * Grid responsivo e interface fluida.
* Persistir **preferências do usuário** e **favoritos** com `SharedPreferences`.

---

## 📦 Estrutura de Pastas

```
lib/
 ├── repository/
 │    └── gif_repository.dart         # Camada de acesso aos dados
 ├── services/
 │    └── giphy_service.dart          # Comunicação com a API do Giphy
 ├── theme/
 │    └── theme_notifier.dart         # Controle de tema claro/escuro
 ├── ui/
 │    └── screens/
 │         ├── random_gif_page.dart   # Tela principal com busca e grid
 │         ├── favorites_page.dart    # Lista de GIFs favoritos
 │         ├── history_page.dart      # Histórico de GIFs visualizados
 │         └── settings_page.dart     # Tela de configurações
 └── main.dart                        # Ponto de entrada do app
```

---

## ⚙️ Funcionalidades Implementadas

### 🔍 Tela Principal (`RandomGifPage`)

* Exibe **GIFs aleatórios** com base em uma **tag** opcional.
* Campo de busca com **debounce (600ms)**.
* Atualização automática configurável.
* Botão de **favoritar GIFs**.
* Acesso rápido a:

  * Histórico de GIFs vistos.
  * Tela de favoritos.
  * Tela de configurações.

### 💾 Persistência de Dados

Todos os dados locais são salvos via **SharedPreferences**:

* GIFs Favoritos
* Histórico de buscas
* Tema (claro/escuro)
* Preferências de idioma, rating e autoplay

### ⚙️ Tela de Configurações (`SettingsPage`)

* Define preferências como:

  * Classificação de conteúdo (`Leve`, `Moderado`, `Sensível`, `Altamente Sensível`)
  * Idioma
  * Quantidade de GIFs exibidos
  * Atualização automática
  * Tema escuro
* As preferências são **persistidas automaticamente** e refletidas no app.

### ❤️ Tela de Favoritos (`FavoritesPage`)

* Lista de GIFs marcados como favoritos.
* Remoção individual ou total.
* Sincronização automática com a tela principal.

### 🕓 Tela de Histórico (`HistoryPage`)

* Exibe últimos GIFs visualizados.
* Possibilidade de limpar o histórico.

---

## 🧠 Decisões Técnicas

* Utilização de `Future` e `async/await` para operações assíncronas.
* `setState()` para gerenciamento de estado simples (sem dependências externas).
* Estrutura modular, separando responsabilidades (Service, Repository, UI).
* `SharedPreferences` para armazenamento local multiplataforma.
* `Timer` e `debounce` para otimizar busca e atualização automática.

---

## 🚀 Como Rodar o Projeto

1. **Clone o repositório**

   ```bash
   git clone https://github.com/seu-usuario/gif_flutter.git
   cd gif_flutter
   ```

2. **Instale as dependências**

   ```bash
   flutter pub get
   ```

3. **Execute o app**

   ```bash
   flutter run
   ```

> 💡 É necessário ter o Flutter SDK instalado e configurado em sua máquina.

---

## 🔑 Caso os GIFs não apareçam

Se ao executar o app **nenhum GIF for exibido**, pode ser que a **chave da API do Giphy** usada no projeto tenha expirado ou atingido o limite de uso gratuito.

Para corrigir:

1. Acesse [https://developers.giphy.com/](https://developers.giphy.com/).
2. Crie uma conta (ou entre na sua).
3. Gere uma nova **API Key**.
4. Substitua a chave antiga no arquivo:

   ```
   lib/services/giphy_service.dart
   ```

   Exemplo:

   ```dart
   static const String _apiKey = 'SUA_NOVA_CHAVE_AQUI';
   ```
5. Salve o arquivo e rode novamente o app:

   ```bash
   flutter run
   ```

---

## 🧩 Dependências Principais

* `http` → Requisições para a API do Giphy.
* `shared_preferences` → Armazenamento local de dados.
* `flutter/material.dart` → Componentes visuais padrão do Flutter.

---

## 📱 Preview (Funcionalidades)

* ✅ Busca com debounce
* ✅ Favoritar e desfavoritar GIFs
* ✅ Histórico de visualizações
* ✅ Tema claro/escuro
* ✅ Configurações persistentes

