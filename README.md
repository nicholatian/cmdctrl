# Command &amp; Control

Scripts for orchestrating multi-master web servers.

---

## Updating website content

The file `push.sh` is meant to be syndicated into the `util/` subfolders
of the various website sources, where it can be integrated into a build
system like Make. `push.sh` takes a two-column CSV file as input for its
list of sources and their server-side destinations; see
`etc/publish.csv` for an idea of what that may look like.

In practise, `push.sh` always expects to be run from `util/` in the
source tree with `etc/publish.csv` available as described. It takes a
single parameter `$1` which is treated as the hostname (or IP address)
to `rsync` the list of files to.

## Let&rsquo;s Encrypt synchronisation

Synching _Lets&rsquo;s Encrypt_ configuration data is needed so that all
servers can handle HTTPS harmoniously. It is assumed that this process
is started from one server where the working certificates and
configuration settings reside.

Create a new SSH keypair for _Let&rsquo;s Encrypt_ propagation:

```sh
ssh-keygen -qt rsa -b 4096 -N '' -f "$HOME/.ssh/httpsync"
```

Log in to each of the other nodes and do the following as `root`:
1. `useradd -md /var/cache/httpsync httpsync`
2. `su - httpsync`
3. Using `nano` on the server, paste the contents of the
   `$HOME/.ssh/httpsync.pub` file created on the client before into the
   `$HOME/.ssh/authorized_keys` file on the server
4. `chmod 700 "$HOME/.ssh"`
5. `chmod 600 "$HOME/.ssh/authorized_keys"`

Now it is practical to sync the _Let&rsquo;s Encrypt_ configuration
settings (swap out `@HOSTNAME@` with the target hostname or IP address):

```sh
host=@HOSTNAME@
rsync -avze 'ssh -qi "$HOME/.ssh/httpsync"' \
	/etc/letsencrypt \
	"httpsync@$host:/var/cache/httpsync"
```

An almost identical script is provided as `src/tls-send.sh` that takes
one argument `$1` as the host. Installing it into a live system permits
easier cronjob integration as then it can just be called repeatedly for
each of the real hostnames using the live `/etc/hosts` (as is best
practise).

`tls-send.sh` should be run **monthly** on the server originating the
TLS certificates. `tls-recv.sh` should be run **daily** on all the
receiving servers that the originating server sent to via `tls-send.sh`.

### Adding domains to the fray

DNS based authentication using the Cloudflare&trade; API is needed since
the default file-based HTTP authentication will not work with multiple
A/AAAA records in use. This preference is saved after certificate
creation in `/etc/letsencrypt` so it is automatically recalled later by
`certbot renew`.

```sh
certbot certonly --dns-cloudflare \
--dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini \
--dns-cloudflare-propagation-seconds 30 \
--preferred-challenges dns-01 \
-d @DOMAIN@
# and so on...
```

After this, run `tls-send.sh` so the fresh certificates get picked up by
the other servers in a timely fashion.

## Website configuration

nginx is run as the `nginx` user with the configuration directory as
`/etc/nginx` and the user&rsquo;s `$HOME` as `/var/lib/nginx`. Every
server should `usermod -s /bin/sh nginx` so `push.sh` can function from
developer machines.

`push.sh` and all of the site configuration files expect the public HTML
directories to be contained within `/var/lib/nginx/public/${website}`,
where `${website}` is a reverse dot notation of a full domain name
corresponding to a `.conf` file inside `/etc/nginx/available/` for the
same. For example, the Cmd&amp;Ctrl sources here provide a
`mt.xion.irc.conf` file for `irc.xion.mt`, which expects its root to be
`/var/lib/nginx/public/mt.xion.irc`.

To obviate the need for every development machine to sync its public SSH
key to every public edge server, the technique from
_Let&rsquo;s Encrypt_ propagation is borrowed; the `httpsync` account
is used to stage new static files, which are `rsync`ed every 15 minutes
by a cronjob running the `src/www-send.sh` script. A cronjob on the
other servers runs `src/www-recv.sh` every 15 minutes to scoop up the
files from `httpsync`&rsquo;s unprivileged home directory and merge them
into the live root.

### Configuration files

On each server, download a snapshot of this repository and run
`util/install-www.sh`. This will make backups of any stock files to be
replaced, which can be restored along with removal of the remaining
installation by running `util/uninstall-www.sh`.
