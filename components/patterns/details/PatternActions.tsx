'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { useSession } from 'next-auth/react'
import Link from 'next/link'
import { Button } from '@/components/ui/button'
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '@/components/ui/sheet'
import { Pencil, Trash2 } from 'lucide-react'
import { toast } from 'sonner'
import { deletePattern } from '@/lib/api/patterns'
import { hasRole } from '@/lib/types/auth'

type PatternActionsProps = {
  slug: string
  patternId: string
}

export function PatternActions({ slug, patternId }: PatternActionsProps) {
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false)
  const [isDeleting, setIsDeleting] = useState(false)
  const router = useRouter()
  const { data: session, status } = useSession()

  // Don't render while session is loading or if user is not an editor/admin
  if (status === 'loading' || !hasRole(session?.user?.roles, 'Editor')) {
    return null
  }

  const handleDelete = async () => {
    setIsDeleting(true)
    try {
      await deletePattern(patternId, session?.accessToken)
      setShowDeleteConfirm(false)
      router.push('/patterns')
    } catch {
      toast.error('Failed to delete pattern. Please try again.')
    } finally {
      setIsDeleting(false)
    }
  }

  return (
    <>
      <div className="flex items-center gap-2">
        <Button variant="outline" size="sm" asChild>
          <Link href={`/patterns/${slug}/edit`}>
            <Pencil className="h-4 w-4 mr-2" />
            Edit
          </Link>
        </Button>

        <Button
          variant="outline"
          size="sm"
          className="text-destructive hover:text-destructive"
          onClick={() => setShowDeleteConfirm(true)}
        >
          <Trash2 className="h-4 w-4 mr-2" />
          Delete
        </Button>
      </div>

      <Sheet open={showDeleteConfirm} onOpenChange={setShowDeleteConfirm}>
        <SheetContent side="bottom" className="sm:max-w-md sm:mx-auto">
          <SheetHeader>
            <SheetTitle>Delete Pattern?</SheetTitle>
            <SheetDescription>
              This action cannot be undone. This will permanently delete the
              pattern.
            </SheetDescription>
          </SheetHeader>
          <div className="flex gap-3 mt-6">
            <Button
              variant="outline"
              className="flex-1"
              onClick={() => setShowDeleteConfirm(false)}
              disabled={isDeleting}
            >
              Cancel
            </Button>
            <Button
              variant="destructive"
              className="flex-1"
              onClick={handleDelete}
              disabled={isDeleting}
            >
              {isDeleting ? 'Deleting...' : 'Delete'}
            </Button>
          </div>
        </SheetContent>
      </Sheet>
    </>
  )
}
