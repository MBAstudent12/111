#!/bin/bash -e

DIR=$(dirname $(readlink -f "$0"))
PLATFORM="${1:-Xeon}"
SCENARIO="$(echo ${2:-traffic} | tr ',' '/')"
NOFFICES="${3:-1}"
IFS="," read -r -a NCAMERAS <<< "${4:-5}"
IFS="," read -r -a NANALYTICS <<< "${5:-3}"
FRAMEWORK="${6:-gst}"
NETWORK="${7:-FP32}"
REGISTRY="$8"
RELEASE="${RELEASE:-:latest}"
HOSTIP=$(ip route get 8.8.8.8 | awk '/ src /{split(substr($0,index($0," src ")),f);print f[2];exit}')

case "N$SCOPE" in
    N | Ncloud | Noffice*-svc | Noffice*-camera | Noffice*) ;;
    *)
        echo "Unsupported scope: $SCOPE"
        exit 1 ;;
esac

echo "Generating helm chart with PLATFORM=${PLATFORM}, SCENARIO=${SCENARIO}, NOFFICES=${NOFFICES}"
m4 -DHA_CLOUD=${HA_CLOUD:-1} -DHA_OFFICE=${HA_OFFICE:-1} -DHA_SRS_OFFICE=${HA_SRS_OFFICE:-1} -DBUILD_SCOPE=${SCOPE} -DREGISTRY_PREFIX=${REGISTRY} -DRELEASE_SUFFIX=${RELEASE} -DNOFFICES=${NOFFICES} -DSCENARIO=${SCENARIO} -DPLATFORM=${PLATFORM} -DNCAMERAS=${NCAMERAS[0]} -DNCAMERAS2=${NCAMERAS[1]:-${NCAMERAS[0]}} -DNCAMERAS3=${NCAMERAS[2]:-${NCAMERAS[1]:-${NCAMERAS[0]}}} -DNANALYTICS=${NANALYTICS[0]} -DNANALYTICS2=${NANALYTICS[1]:-${NANALYTICS[0]}} -DNANALYTICS3=${NANALYTICS[2]:-${NANALYTICS[1]:-${NANALYTICS[0]}}} -DFRAMEWORK=${FRAMEWORK} -DNETWORK_PREFERENCE=${NETWORK} -DUSERID=$(id -u) -DGROUPID=$(id -g) -DHOSTIP=${HOSTIP} -I "${DIR}/helm" "$DIR/helm/values.yaml.m4" > "$DIR/helm/values.yaml"
