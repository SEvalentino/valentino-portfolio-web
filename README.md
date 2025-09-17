# Valentino Portfolio (Static)
A sleek, interview-ready portfolio site to showcase DevOps/Cloud skills.

## Run locally
```bash
docker build -t valentino-portfolio:dev .
docker run --rm -p 8088:80 valentino-portfolio:dev
# open http://localhost:8088
```

## Build & Push (Artifact Registry)
Replace <PROJECT_ID> as needed.
```bash
IMAGE=asia-southeast1-docker.pkg.dev/<PROJECT_ID>/portfolio-repo/valentino-portfolio:latest
docker build -t $IMAGE .
docker push $IMAGE
```

## Helm deploy (reuse your existing chart)
- Set `image.repository` to `asia-southeast1-docker.pkg.dev/<PROJECT_ID>/portfolio-repo/valentino-portfolio`
- Set `image.tag` to your tag (`latest` or from CI)
- Service type LoadBalancer (or Ingress if you add a domain + TLS)

## Notes
- Pure static: edit `index.html` & `styles.css` to customize content.
- Add project cards/screenshots inside `/assets` and update the HTML.
