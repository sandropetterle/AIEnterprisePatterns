import ReactMarkdown from 'react-markdown'
import remarkGfm from 'remark-gfm'
import rehypeSanitize from 'rehype-sanitize'

type PatternContentProps = {
  content: string
}

export function PatternContent({ content }: PatternContentProps) {
  return (
    <div className="prose prose-slate dark:prose-invert max-w-none">
      <ReactMarkdown
        remarkPlugins={[remarkGfm]}
        rehypePlugins={[rehypeSanitize]}
        components={{
          h2: ({ ...props }) => (
            <h2 className="text-2xl font-bold mt-8 mb-4 pb-2 border-b" {...props} />
          ),
          h3: ({ ...props }) => (
            <h3 className="text-xl font-semibold mt-6 mb-3" {...props} />
          ),
          h4: ({ ...props }) => (
            <h4 className="text-lg font-semibold mt-4 mb-2" {...props} />
          ),
          p: ({ ...props }) => <p className="mb-4 leading-7" {...props} />,
          ul: ({ ...props }) => (
            <ul className="list-disc list-inside mb-4 space-y-2" {...props} />
          ),
          ol: ({ ...props }) => (
            <ol className="list-decimal list-inside mb-4 space-y-2" {...props} />
          ),
          li: ({ ...props }) => <li className="ml-4" {...props} />,
          a: ({ ...props }) => (
            <a
              className="text-primary hover:underline font-medium"
              target="_blank"
              rel="noopener noreferrer"
              {...props}
            />
          ),
          code: ({ className, children, ...props }) => {
            const isInline = !className
            return isInline ? (
              <code
                className="bg-muted px-1.5 py-0.5 rounded text-sm font-mono"
                {...props}
              >
                {children}
              </code>
            ) : (
              <code
                className={`block bg-muted p-4 rounded-lg overflow-x-auto text-sm font-mono ${className || ''}`}
                {...props}
              >
                {children}
              </code>
            )
          },
          pre: ({ children, ...props }) => (
            <pre className="mb-4 overflow-hidden rounded-lg" {...props}>
              {children}
            </pre>
          ),
          blockquote: ({ ...props }) => (
            <blockquote
              className="border-l-4 border-primary pl-4 italic my-4"
              {...props}
            />
          ),
          table: ({ ...props }) => (
            <div className="overflow-x-auto mb-4">
              <table className="min-w-full divide-y divide-border" {...props} />
            </div>
          ),
          th: ({ ...props }) => (
            <th
              className="px-4 py-2 bg-muted font-semibold text-left"
              {...props}
            />
          ),
          td: ({ ...props }) => (
            <td className="px-4 py-2 border-t border-border" {...props} />
          ),
        }}
      >
        {content}
      </ReactMarkdown>
    </div>
  )
}
