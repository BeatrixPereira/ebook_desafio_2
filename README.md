# Flutter eBook Reader

Este é um aplicativo Flutter para leitura de eBooks que oferece uma experiência interativa e fácil de usar para os usuários.

## Funcionalidades

### 1. Baixar Lista de Livros e Capas:

O aplicativo acessa uma API para baixar uma lista atualizada de livros e suas respectivas capas.

### 2. Estante de Livros:

Exibe as capas dos livros baixados de forma organizada em uma estante virtual.

### 3. Download e Armazenamento de Livros:

Permite que o usuário baixe um livro ao tocar em sua capa e salve o arquivo no dispositivo.

### 4. Exibição de Livros:

Utiliza o plugin [Vocsy Epub Viewer](https://pub.dev/packages/vocsy_epub_viewer) para exibir o conteúdo do livro.

### 5. Navegação de Interface:

Inclui um botão para que o usuário possa retornar facilmente à estante de livros durante a leitura.

### 6. Favoritos (Feature Bônus)

- Aba de favoritos: Toque em "Favoritos" para exibir apenas os livros favoritos.
- Para favoritar um livro, toque no marcador no canto superior direito na estante inicial.
- Os livros favoritos são persistidos mesmo ao fechar o aplicativo.
- Em um livro favorito, o marcador aparece em vermelho. Toque novamente para remover da lista de favoritos.


## Instalação

Certifique-se de ter o Flutter na versão 3.16 instalado em sua máquina.

```bash
flutter pub get
flutter run