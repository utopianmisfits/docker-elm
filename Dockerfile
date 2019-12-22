FROM node:12.13.1-buster-slim

ENV ELM_VERSION=0.19.1
ENV ELM_URL=https://github.com/elm/compiler/releases/download/${ELM_VERSION}/binary-for-linux-64-bit.gz

ENV ELM_FORMAT_VERSION=0.8.2
ENV ELM_FORMAT_URL=https://github.com/avh4/elm-format/releases/download/${ELM_FORMAT_VERSION}/elm-format-${ELM_FORMAT_VERSION}-linux-x64.tgz

RUN wget -O - ${ELM_URL} | gunzip -c >/usr/local/bin/elm
RUN chmod +x /usr/local/bin/elm

RUN wget -O - ${ELM_FORMAT_URL} | gunzip -c >/usr/local/bin/elm-format
RUN chmod +x /usr/local/bin/elm-format

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
    elm-oracle \
    elm-analyse \
  && npm cache clean --force

RUN ln -s /opt/node_modules/.bin/* /usr/local/bin/

# Elm-test will try to download the elmi-to-json on the first time that it runs
# RUN cd /tmp \
#   && mkdir -p elm-test-example/src \
#   && mkdir -p elm-test-example/tests \
#   && cd elm-test-example \
#   && echo '{                  \
#     "type": "application",    \
#     "source-directories": [   \
#         "src"                 \
#     ],                        \
#     "elm-version": "0.19.1",  \
#     "dependencies": {         \
#         "direct": {           \
#             "elm/browser": "1.0.2", \
#             "elm/core": "1.0.4",    \
#             "elm/html": "1.0.0"     \
#         },                          \
#         "indirect": {               \
#             "elm/json": "1.1.3",    \
#             "elm/time": "1.0.0",    \
#             "elm/url": "1.0.0",     \
#             "elm/virtual-dom": "1.0.2"  \
#         }                               \
#     },                                  \
#     "test-dependencies": {              \
#         "direct": {                     \
#           "elm-explorations/test": "1.2.2" \
#         },                              \
#         "indirect": {                   \
#           "elm/random": "1.0.0"         \
#         }                               \
#     }                                   \
# }' > elm.json \
#   && echo '\n\
# module ElmTest exposing (..) \n\
# import Expect exposing (Expectation) \n\
# import Fuzz exposing (Fuzzer, int, list, string) \n\
# import Test exposing (..) \n\
# \n\
# suite : Test                                                             \n\
# suite =                                                                  \n\
#   describe "The String module"                                           \n\
#     [ test "has no effect on a palindrome" <|                      \n\
#         \_ ->                                                      \n\
#             let                                                    \n\
#                 palindrome =                                       \n\
#                     "hannah"                                       \n\
#             in                                                     \n\
#                 Expect.equal palindrome (String.reverse palindrome) \n\
#     ] \n\
# ' > tests/ElmTest.elm

# RUN cd /tmp/elm-test-example/ && elm-test

ENTRYPOINT ["elm"]

