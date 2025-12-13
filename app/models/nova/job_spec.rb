module Nova
  class JobSpec
    def self.build(worker, task)
      new(worker, task).build
    end

    def initialize(worker, task)
      @worker = worker
      @task = task
    end

    def build
      {
        apiVersion: "batch/v1",
        kind: "Job",
        metadata: {
          name: @worker.name,
          labels: {
            app: "nova-worker",
            task_id: @task.id
          }
        },
        spec: {
          ttlSecondsAfterFinished: 10,
          activeDeadlineSeconds: 3600,
          backoffLimit: 0,
          template: {
            spec: {
              restartPolicy: "Never",
              containers: [
                worker_container,
                dind_container
              ],
              volumes: volumes
            }
          }
        }
      }
    end

    private

    def worker_container
      {
        name: "worker",
        image: "registry.digitalocean.com/saturnci/nova-worker-agent:latest",
        imagePullPolicy: "Always",
        resources: {
          requests: { cpu: "250m", memory: "256Mi" }
        },
        env: [
          { name: "SATURNCI_API_HOST", value: ENV.fetch("SATURNCI_HOST") },
          { name: "WORKER_ID", value: @worker.id },
          { name: "WORKER_ACCESS_TOKEN", value: @worker.access_token.value },
          { name: "TASK_ID", value: @task.id },
          { name: "DOCKER_HOST", value: "tcp://localhost:2375" },
          { name: "BUILDX_CACHE_PATH", value: "/buildx-cache" }
        ],
        volumeMounts: [
          { name: "repository", mountPath: "/repository" },
          { name: "docker-config", mountPath: "/root/.docker" },
          { name: "buildx-cache", mountPath: "/buildx-cache" }
        ]
      }
    end

    def dind_container
      {
        name: "dind",
        image: "docker:24-dind",
        securityContext: { privileged: true },
        args: [
          "--host=tcp://0.0.0.0:2375",
          "--registry-mirror=https://dockerhub-proxy.saturnci.com:5000",
          "--insecure-registry=docker-image-registry-service:5000"
        ],
        resources: {
          requests: { cpu: "1250m", memory: "3072Mi" }
        },
        env: [
          { name: "DOCKER_TLS_CERTDIR", value: "" }
        ],
        volumeMounts: [
          { name: "dind-storage", mountPath: "/var/lib/docker" },
          { name: "repository", mountPath: "/repository" },
          { name: "docker-config", mountPath: "/root/.docker" },
          { name: "buildx-cache", mountPath: "/buildx-cache" }
        ]
      }
    end

    def volumes
      [
        { name: "dind-storage", hostPath: { path: dind_storage_path, type: "DirectoryOrCreate" } },
        { name: "buildx-cache", hostPath: { path: buildx_cache_path, type: "DirectoryOrCreate" } },
        { name: "repository", emptyDir: {} },
        { name: "docker-config", emptyDir: {} }
      ]
    end

    def dind_storage_path
      repository = @task.test_suite_run.repository
      test_suite_run = @task.test_suite_run
      "/var/lib/saturnci-docker/#{repository.abbreviated_hash}/#{test_suite_run.abbreviated_hash}/#{@task.abbreviated_hash}"
    end

    def buildx_cache_path
      repository = @task.test_suite_run.repository
      "/var/lib/saturnci-buildx-cache/#{repository.abbreviated_hash}/#{@task.order_index}"
    end
  end
end
