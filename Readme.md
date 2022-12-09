## Documentación de Python

### How to start?

### How to build?

- For buld html documntation execute the next command:

    - `gradle asciidoctor`

- This command generate a dirrectore with the `html` files of the project then you can execute the next command to open the documentation on your browser
 
    - `open build/docs/ref-docs/html5/index.html`


### Referencias de plugins usados
- [grgit](https://github.com/ajoberstar/grgit)
- [gradle-git-publish](https://github.com/ajoberstar/gradle-git-publish)

### Configuraciones previas

Crear las siguientes variables de ambiente
```
GRGIT_USER=somebody
GRGIT_PASS=myauthtoken
```

### Proceso de construcción

- Ejecutar la siguiente tarea de Gradle

```
./gradlew asciidoctor
```

- Posteriormente ejecutar la siguiente tarea para la publicación de nuestra documentación
```
./gradlew gitPublishPush
```
