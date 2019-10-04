# minexp
What this is: a minimal exp template (for heroku)
It shows an instruction preamble, asks some basic demographics questions, has two demo questions with response buttons, and provides a dashboard page where you can download the results.
Most of the action is in exp.js and admin.js.

# Setup steps
This doesn't work out of the box, some setup is required.

```npm install```

add ```.env``` and ```.gitignore```

One critical component of .env is your db credentials, for local testing with postgres this is a line of the form DATABASE_URL=postgres://name:pwd@localhost:port/username

You'll want to set a unique cookie secret in .env. Go to index.js and replace 'not_the_actual_secret' in the session setup with a reference to process.env.WHATEVERYOUCALLEDIT.

A reasonable default .gitignore might be:

```
# Node build artifacts
node_modules
npm-debug.log

# Local development
*.env
*.dev
.DS_Store
*RData
*.png
```
Assuming you have heroku and your database already set to go, at this point you should be ready to test locally with ```heroku local web```

If you want more structure in the saved data than a monolithic "responses" table, there are three places you need to change. Create the table on the database itself so you can write to it. Then the $post at the save-point should direct to a new table-handler in index.js, and also the dashboard (and index.js getter) will need a new button to download the new table as a csv. This would be a whole lot less ugly if I knew more about express.

To deploy:

```heroku create myprojectname``` will appear at myprojectname.herokuapp.com, navigate there or use the ```heroku open``` CLI shortcut.

You will need to provision the database. This line works for postgres, but there's no hard requirement to use that.

```heroku addons:create heroku-postgresql:hobby-dev```

Check if you actually want to upgrade from hobby-dev. (Probably not)

Then use ```heroku pg:psql``` to connect to the db so you can ```create table``` there or whatever you need to do to setup.

Logs and other fun things can be accessed through dashboard.heroku.com

```git push heroku master``` to deploy the latest version. To take it down, ```heroku apps:destroy``` or delete from the dashboard page (bottom of 'settings')