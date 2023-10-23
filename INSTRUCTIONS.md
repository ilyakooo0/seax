# Installation Instructions

1. Create a folder and name it whatever you want. 

```bash
$ mkdir seax-project
$ cd seax-project
```
2. Inside the folder, `clone` the **airlock** library and the **seax** project.

```bash
$ git clone https://github.com/ilyakooo0/airlock
$ git clone https://github.com/ilyakooo0/seax
```
3. Download the v2.11 pill.

```bash
$ wget https://bootstrap.urbit.org/urbit-v2.11.pill
```
4. Start your fake zod using the pill.

```bash
$ urbit -B urbit-v2.11.pill -F zod
```

5. Now, inside dojo run the following:
```bash
dojo> |new-desk %seax
dojo> |mount %seax
```

6. Back in your shell, run:
```bash
$ rm -r zod/seax
$ cp -r seax/zod/seax zod/seax
```

7. In the dojo install the seax agent and allow cross-site origin requests from localhost.
```bash
dojo> |commit %seax
dojo> |install our %seax
dojo> |pass [%e [%approve-origin 'http://localhost:8000']]
```

8. While your urbit is running in another terminal run:
```bash
$ ./seax/dev/elm-live.sh
```
The above command will start the frontend which communicates with your zod ship 
using the Elm airlock library.

Now, you can go to your browser at `http://localhost:8000/`.
The seax app should be displaying a search bar. You might need to refresh the page once before using the app.
You'll know that everything works if you see the "< ~zod: Opening airlock!" message in your dojo. 

# Usage Instructions

Now, you can fill in the search bar with any term you like.
Clicking "search" will iniate collect any relevant results from the configured search sources.
In the results page, you can click on any of the sources to filter to only results from that source.
