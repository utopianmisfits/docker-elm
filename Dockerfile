FROM node:12.13.1-alpine

ENV ELM_VERSION=0.19.1
ENV ELM_URL=https://github.com/elm/compiler/releases/download/${ELM_VERSION}/binary-for-linux-64-bit.gz

RUN wget -O - ${ELM_URL} | gunzip -c >/usr/local/bin/elm
RUN chmod +x /usr/local/bin/elm

# This process is a bit different.
# We are installing each "global" package as a local package inside /opt and
# then we symlink it to /usr/local/bin manually
#
# The reason why we do this, is to have an easy access to the `npm audit`
# command, which is a really important command that notify us whenever we
# install a dependency with a known vulnerability.
#
# This check is not done for real global packages
RUN cd /opt \
  && npm install --production --no-save --ignore-scripts --no-package-lock \
    elm-test \
    elm-verify-examples \
    elm-format \
    elm-oracle \
    elm-analyse \
  && npm cache clean --force

RUN ln -s /opt/node_modules/.bin/* /usr/local/bin/


ENTRYPOINT ["elm"]

