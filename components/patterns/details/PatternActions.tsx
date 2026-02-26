'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { useSession } from 'next-auth/react'
import Link from 'next/link'
import { Button } from '@/components/ui/button'
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from '@/components/ui/alert-dialog'
import { Pencil, Trash2 } from 'lucide-react'
import { toast } from 'sonner'
import { deletePattern } from '@/lib/api/patterns'
import { hasRole } from '@/lib/types/auth'

type PatternActionsProps = {
  slug: string
  patternId: string
  editLabel?: string
  deleteLabel?: string
  deleteDialogTitle?: string
  deleteDialogDescription?: string
  cancelLabel?: string
  deleteConfirmLabel?: string
  deletingLabel?: string
}

export function PatternActions({
  slug,
  patternId,
  editLabel = 'Edit',
  deleteLabel = 'Delete',
  deleteDialogTitle = 'Delete Pattern?',
  deleteDialogDescription = 'This action cannot be undone. This will permanently delete the pattern.',
  cancelLabel = 'Cancel',
  deleteConfirmLabel = 'Delete',
  deletingLabel = 'Deleting...',
}: PatternActionsProps) {
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
      router.push('/patterns')
    } catch {
      toast.error('Failed to delete pattern. Please try again.')
    } finally {
      setIsDeleting(false)
    }
  }

  return (
    <div className="flex items-center gap-2">
      <Button variant="outline" size="sm" asChild>
        <Link href={`/patterns/${slug}/edit`}>
          <Pencil className="h-4 w-4 mr-2" />
          {editLabel}
        </Link>
      </Button>

      <AlertDialog>
        <AlertDialogTrigger asChild>
          <Button
            variant="outline"
            size="sm"
            className="text-destructive hover:text-destructive"
          >
            <Trash2 className="h-4 w-4 mr-2" />
            {deleteLabel}
          </Button>
        </AlertDialogTrigger>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>{deleteDialogTitle}</AlertDialogTitle>
            <AlertDialogDescription>
              {deleteDialogDescription}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel disabled={isDeleting}>{cancelLabel}</AlertDialogCancel>
            <AlertDialogAction
              onClick={handleDelete}
              disabled={isDeleting}
              className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
            >
              {isDeleting ? deletingLabel : deleteConfirmLabel}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  )
}
