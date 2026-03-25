MMU FYP RENDER FORMATE ACCORDING TO THE HANDBOOK's EXACT SPECIFICATIONs.


# Overview

This repo aims to help you replace typical word processors such as microsoft word or libreOffice writer with a more intutive and powerful tool called quarto for your MMU FYP interim report.

This should let you focus on the content of your paper rather than the formatting.

What is quarto ? an open-source scientific and technical publishing system (https://quarto.org/).

It's very important to know how quarto operates on a basic level before using it, while it uses many different technologies and can extend to a wide range of use cases, this is what our set up uses.

Under the hood quarto uses these 3 technologies.

1. **Markdown** is a lightweight markup language that uses plain-text formatting syntax. It’s designed to be easy to read and easy to write, even before it’s "rendered" into its final form, this is what you will be using to write your paper before it turns into a PDF, you will need basic markdown writing knowledge (it can be learnt in less than 30 mins https://www.markdownguide.org/basic-syntax/).


Before reading about typst you need to know this:
A typesetting system is a piece of software that takes your raw text and automatically turns it into a professionally designed document.

The Gold standard for this is actually LaTeX, it is a typesetting system that has been around for decades and is widely used in academia. It is known for its high-quality output and its extensive features. However, it is also known for its steep learning curve and its complex syntax.

2. **Typst** is a modern, markup-based typesetting system designed to be an alternative to LaTeX. It is built in Rust, making it incredibly fast, and it produces high-quality PDFs with a much lower learning curve than its predecessor Latex (Latex is also supported by quarto). You can see our typst format code for the interim report at *_extensions/mmu-fyp/typst-template.typ*.

3. **Pandoc** is the universal document converter. It is a command-line tool that can transform files from one markup format into another (e.g., Markdown to Word, HTML to PDF, or LaTeX to Typst).

Quarto itself does not CONVERT, RENDER OR EDIT documents, it is an orchestrator for the all the other 3 tools, making using them much easier and intuitive.

## Why quarto? why use a typesetting system instead of word processors?

Word processors are great for short documents such as letters or company reports, but they are not designed for medium to long academic papers, you will often find yourself fighting the software to get the formatting right and its very easy to make a simple change and break the entire document, overall very unintuitive, distracting and time consuming for academic writing.

Typesetting produces perfectly replicable professional looking documents according to whatever standard you need (in our case the MMU handbook), it's also a must for professional academic writing and publishing.

Quarto allows you to use markdown or even other markup languages to produce a professional document with minimal effort, and thanks to pandoc it can be used a write once publish anywhere tool, different publishing articles have different formatting requirements, with quarto you can simply change a few settings and publish to their exact format instead of rewriting your entire paper in whatever they need so it's super helpful for researchers to get their papers accessible in as many places as possible, lastly and arguably the best feature for us as bachelor students who are new to academic writing is the extremly low entry barrier to using quarto, in the past you hard to learn latex and write literal code to produce a paper even with the release to typst which made it much easier, it would still take a large chunk of your time learning it instead of writing your paper, now with quarto you can learn the basics of markdown in less than 30 minutes and quarto handles all the complex formatting for you.


# INSTALL QAURTO [https://quarto.org/docs/get-started/]

use your operating system's installer


if you are on linux you will need to install microsoft's arial for typst to render the proper required font(ignore this if you are on windows).

Debian based:

```sudo apt install ttf-mscorefonts-installer```


Fedora / RHEL / CentOS:

```sudo dnf install mscore-fonts-all```

ARCH:

```sudo pacman -S ttf-ms-fonts```

# INSTALL QUARTO's IDE EXTENSION [https://marketplace.visualstudio.com/items?itemName=quarto.quarto]

this will allow you to preview the document in real time and edit inside your IDE, may IDE extensions are avilable but the best supported is VS code.


# CLONE REPOSITORY

```git clone https://github.com/Heterochromi/FYP1.git```

1.Open the repo directory inside your IDE then navigate to your paper.qmd.

2.Click on the preview button on the top right corner of the IDE (you can also use ```qaurto preview paper.qmd``` in the terminal if you don't have an extension).

3.You should see a rendered pdf on the right side of your screen or in your browser if you used the terminal.

4.Your pdf should be inside the same directory as paper.qmd named paper.pdf.

5.You are done, You can go ahead and start writing your paper!!!!

optional recommendation: delete the .git directory so you can push your own repo if needed.