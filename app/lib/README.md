**What's the difference between /app/lib and just /lib??**

Simple: `app/lib` is on the autoload path, `lib` is not. (But `lib` is still on
the *load* path, meaning that the files are still available if you want to
`require` them manually.)

If it's 'app code' that will be needed during normal execution of the app in a
production environment, it probably belongs in  `app/lib`. If it's code that
only gets used in certain contexts (e.g. in background jobs or rake tasks), it
might belong in `lib`.

Remember that when the autoloader is running (i.e. in the development
environment), the same file can be loaded multiple times, which will cause
headaches if they e.g. alter global state that persists from request to
request. If you have a file like this, it's probably a sign that the file is
badly designed and should be altered, but if you really can't alter it (see
e.g. `lib/types.rb`), then this is a good use case for the `lib` dir - stick it
in `lib`, then require it once in somewhere like `config/application.rb`
