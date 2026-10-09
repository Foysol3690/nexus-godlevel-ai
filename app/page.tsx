import { Download } from 'lucide-react'

export default function Page() {
  return (
    <main className="relative flex min-h-dvh items-center justify-center bg-[#02040A] sm:p-6">
      <h1 className="sr-only">NEXUS home screen preview</h1>
      <a
        href="/downloads/nexus_flutter.zip"
        download="nexus_flutter.zip"
        className="fixed bottom-4 right-4 z-10 inline-flex min-h-11 items-center gap-2 rounded-full border border-white/15 bg-white/10 px-4 text-sm font-medium text-white backdrop-blur-md transition-colors hover:bg-white/20 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-cyan-300"
      >
        <Download className="size-4" aria-hidden="true" />
        Download Flutter ZIP
      </a>
      <div className="h-dvh w-full overflow-hidden sm:h-[min(860px,calc(100dvh-3rem))] sm:w-auto sm:aspect-[9/19.5] sm:rounded-[2.5rem] sm:border sm:border-white/10 sm:shadow-[0_0_80px_-20px_rgba(63,230,255,0.25)]">
        <iframe
          src="/nexus/index.html"
          title="NEXUS Flutter home screen"
          allow="microphone"
          className="block h-full w-full border-0"
        />
      </div>
    </main>
  )
}
