export default function Loading() {
  return (
    <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div className="space-y-8 animate-pulse">
        {/* Hero skeleton */}
        <div className="space-y-4">
          <div className="h-12 bg-muted rounded w-3/4" />
          <div className="h-6 bg-muted rounded w-1/2" />
        </div>

        {/* Featured patterns skeleton */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {[1, 2, 3].map((i) => (
            <div key={i} className="h-64 bg-muted rounded-lg" />
          ))}
        </div>

        {/* Stats skeleton */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {[1, 2, 3].map((i) => (
            <div key={i} className="h-32 bg-muted rounded-lg" />
          ))}
        </div>
      </div>
    </div>
  )
}
